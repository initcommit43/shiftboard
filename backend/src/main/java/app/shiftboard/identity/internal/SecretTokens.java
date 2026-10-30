package app.shiftboard.identity.internal;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.HexFormat;

/** Random tokens handed out once, such as refresh tokens and setup codes, of which only a hash is kept. */
final class SecretTokens {

    private static final int BYTES = 32;

    private static final SecureRandom RANDOM = new SecureRandom();

    private SecretTokens() {
    }

    static String newToken() {
        var bytes = new byte[BYTES];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    static String hash(String token) {
        try {
            var digest = MessageDigest.getInstance("SHA-256").digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
