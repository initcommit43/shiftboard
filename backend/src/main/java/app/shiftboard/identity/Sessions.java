package app.shiftboard.identity;

import java.util.UUID;

public interface Sessions {

    /** Logs the account in: issues an access token and a new refresh token. */
    TokenPair open(UUID accountId);
}
