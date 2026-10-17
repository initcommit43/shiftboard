package app.shiftboard.system;

import javax.sql.DataSource;

import net.javacrumbs.shedlock.core.LockProvider;
import net.javacrumbs.shedlock.provider.jdbctemplate.JdbcTemplateLockProvider;
import net.javacrumbs.shedlock.spring.annotation.EnableSchedulerLock;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Background jobs run with {@code @Scheduled}; ShedLock keeps a job from running on two instances
 * at once (ADR 0023). Switched off with {@code shiftboard.jobs.enabled=false}, as in the tests, which
 * start the jobs themselves.
 */
@Configuration(proxyBeanMethods = false)
@ConditionalOnBooleanProperty(name = "shiftboard.jobs.enabled", matchIfMissing = true)
@EnableScheduling
@EnableSchedulerLock(defaultLockAtMostFor = "PT10M")
class SchedulingConfiguration {

    @Bean
    LockProvider lockProvider(DataSource dataSource) {
        return new JdbcTemplateLockProvider(JdbcTemplateLockProvider.Configuration.builder()
                .withJdbcTemplate(new JdbcTemplate(dataSource))
                // The database clock, so that instances with clocks apart do not take each other's locks.
                .usingDbTime()
                .build());
    }
}
