package app.shiftboard.identity.internal;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.UUID;

import app.shiftboard.identity.Sessions;
import app.shiftboard.identity.TokenPair;
import app.shiftboard.system.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Issues access tokens (JWT) and refresh tokens. A refresh token is an opaque random value
 * of which only the hash is stored; it is single use and replaced on every refresh.
 */
@Service
class SessionService implements Sessions {

    static final String AGENCY_CLAIM = "agency_id";
    static final String ROLE_CLAIM = "role";

    private static final int REFRESH_TOKEN_BYTES = 32;

    private final UserAccountRepository accounts;
    private final RefreshTokenRepository refreshTokens;
    private final JwtEncoder jwtEncoder;
    private final SecurityProperties properties;
    private final SecureRandom random = new SecureRandom();

    SessionService(
            UserAccountRepository accounts,
            RefreshTokenRepository refreshTokens,
            JwtEncoder jwtEncoder,
            SecurityProperties properties) {
        this.accounts = accounts;
        this.refreshTokens = refreshTokens;
        this.jwtEncoder = jwtEncoder;
        this.properties = properties;
    }

    @Override
    @Transactional
    public TokenPair open(UUID accountId) {
        return open(accounts.findById(accountId).orElseThrow());
    }

    @Transactional
    TokenPair open(UserAccount account) {
        var now = Instant.now();
        var refreshToken = newRefreshToken();
        refreshTokens.save(new RefreshToken(account, hash(refreshToken), now.plus(properties.refreshTokenTtl())));
        return new TokenPair(
                accessToken(account, now), refreshToken, Math.toIntExact(properties.accessTokenTtl().toSeconds()));
    }

    @Transactional
    TokenPair refresh(String refreshToken) {
        var tokenHash = hash(refreshToken);
        if (refreshTokens.revokeIfActive(tokenHash, Instant.now()) == 0) {
            throw new ApiException(
                    HttpStatus.UNAUTHORIZED, "invalid_refresh_token", "The refresh token is not valid.");
        }
        return open(refreshTokens.findByTokenHash(tokenHash).orElseThrow().getUserAccountId());
    }

    @Transactional
    void close(String refreshToken) {
        refreshTokens.revokeIfActive(hash(refreshToken), Instant.now());
    }

    private String accessToken(UserAccount account, Instant now) {
        var claims = JwtClaimsSet.builder()
                .subject(account.getId().toString())
                .issuedAt(now)
                .expiresAt(now.plus(properties.accessTokenTtl()))
                .claim(AGENCY_CLAIM, account.getAgencyId().toString())
                .claim(ROLE_CLAIM, account.getRole().name())
                .build();
        var header = JwsHeader.with(MacAlgorithm.HS256).build();
        return jwtEncoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
    }

    private String newRefreshToken() {
        var bytes = new byte[REFRESH_TOKEN_BYTES];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static String hash(String refreshToken) {
        try {
            var digest = MessageDigest.getInstance("SHA-256").digest(refreshToken.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
