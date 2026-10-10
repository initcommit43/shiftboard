package app.shiftboard.identity.internal;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.UUID;

import app.shiftboard.identity.Role;
import org.junit.jupiter.api.Test;

class UserAccountTests {

    @Test
    void storesTheEmailTrimmedAndInLowerCase() {
        var account = new UserAccount(UUID.randomUUID(), "  Mira.Aigner@Example.COM ", "hash", Role.WORKER);

        assertThat(account.getEmail()).isEqualTo("mira.aigner@example.com");
    }
}
