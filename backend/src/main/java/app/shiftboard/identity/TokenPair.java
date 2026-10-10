package app.shiftboard.identity;

/**
 * @param expiresIn lifetime of the access token in seconds
 */
public record TokenPair(String accessToken, String refreshToken, int expiresIn) {
}
