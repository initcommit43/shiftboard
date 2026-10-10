package app.shiftboard.identity;

import java.util.Collection;
import java.util.Map;
import java.util.UUID;

public interface UserAccounts {

    /**
     * Creates an account in the current agency and returns its id.
     *
     * @throws app.shiftboard.system.ApiException {@code email_already_registered} if the email is taken
     */
    UUID register(String email, String password, Role role);

    /** The emails of the given accounts, by account id. */
    Map<UUID, String> emails(Collection<UUID> accountIds);
}
