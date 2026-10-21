package app.shiftboard.system;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * Lets listeners that call outside services, such as push notifications, run in the background
 * instead of in the request that caused them.
 */
@Configuration(proxyBeanMethods = false)
@EnableAsync
class AsyncConfiguration {
}
