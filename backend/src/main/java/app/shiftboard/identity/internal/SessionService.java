package app.shiftboard.identity.internal;

import java.time.Instant;
import java.util.UUID;

import app.shiftboard.agency.Agencies;
import app.shiftboard.agency.TenantContext;
import app.shiftboard.identity.Role;
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
    static final String CLIENT_CLAIM = "client_id";

    private final UserAccountRepository accounts;
    private final RefreshTokenRepository refreshTokens;
    private final JwtEncoder jwtEncoder;
    private final SecurityProperties properties;
    private final Agencies agencies;

    SessionService(
            UserAccountRepository accounts,
            RefreshTokenRepository refreshTokens,
            JwtEncoder jwtEncoder,
            SecurityProperties properties,
            Agencies agencies) {
        this.accounts = accounts;
        this.refreshTokens = refreshTokens;
        this.jwtEncoder = jwtEncoder;
        this.properties = properties;
        this.agencies = agencies;
    }

    @Override
    @Transactional
    public TokenPair open(UUID accountId) {
        return open(accounts.findById(accountId).orElseThrow());
    }

    @Transactional
    TokenPair open(UserAccount account) {
        var now = Instant.now();
        var refreshToken = SecretTokens.newToken();
        refreshTokens.save(
                new RefreshToken(account, SecretTokens.hash(refreshToken), now.plus(properties.refreshTokenTtl())));
        return new TokenPair(
                accessToken(account, now), refreshToken, Math.toIntExact(properties.accessTokenTtl().toSeconds()));
    }

    @Transactional
    TokenPair refresh(String refreshToken) {
        var tokenHash = SecretTokens.hash(refreshToken);
        if (refreshTokens.revokeIfActive(tokenHash, Instant.now()) == 0) {
            throw new ApiException(
                    HttpStatus.UNAUTHORIZED, "invalid_refresh_token", "The refresh token is not valid.");
        }
        var account = accounts.findById(refreshTokens.findByTokenHash(tokenHash).orElseThrow().getUserAccountId())
                .orElseThrow();
        requireAdmitted(account);
        return open(account);
    }

    /**
     * Throws unless the account may have a session: client users only while active and while their
     * agency has the client portal switched on (ADR 0032).
     */
    void requireAdmitted(UserAccount account) {
        if (account.getRole() != Role.CLIENT) {
            return;
        }
        if (account.getStatus() == AccountStatus.DEACTIVATED) {
            throw new ApiException(
                    HttpStatus.FORBIDDEN, "account_deactivated", "The agency has ended the access of this account.");
        }
        boolean portalOn;
        try (var _ = TenantContext.bind(account.getAgencyId())) {
            portalOn = agencies.features().clientPortal();
        }
        if (!portalOn) {
            throw ClientUserService.portalOff();
        }
    }

    @Transactional
    void close(String refreshToken) {
        refreshTokens.revokeIfActive(SecretTokens.hash(refreshToken), Instant.now());
    }

    private String accessToken(UserAccount account, Instant now) {
        var builder = JwtClaimsSet.builder()
                .subject(account.getId().toString())
                .issuedAt(now)
                .expiresAt(now.plus(properties.accessTokenTtl()))
                .claim(AGENCY_CLAIM, account.getAgencyId().toString())
                .claim(ROLE_CLAIM, account.getRole().name());
        if (account.getClientId() != null) {
            builder.claim(CLIENT_CLAIM, account.getClientId().toString());
        }
        var claims = builder.build();
        var header = JwsHeader.with(MacAlgorithm.HS256).build();
        return jwtEncoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
    }


}
