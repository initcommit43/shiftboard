package app.shiftboard.seed;

import static org.assertj.core.api.Assertions.assertThat;

import app.shiftboard.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;

class SeedDataProfileTests extends IntegrationTest {

    @Autowired
    ApplicationContext context;

    @Test
    void nothingIsSeededOutsideTheLocalProfile() {
        var demoAgencies = jdbc.sql("select count(*) from agency where signup_code in (?, ?)")
                .params(SeedData.DONAU_SIGNUP_CODE, SeedData.ALPEN_SIGNUP_CODE)
                .query(Integer.class).single();

        assertThat(context.getBeanNamesForType(SeedData.class)).isEmpty();
        assertThat(demoAgencies).isZero();
    }
}
