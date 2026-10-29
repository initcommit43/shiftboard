package app.shiftboard.identity.internal;

import java.nio.charset.StandardCharsets;
import java.util.Map;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import app.shiftboard.identity.Role;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.security.crypto.password.DelegatingPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.web.servlet.HandlerExceptionResolver;

/**
 * Stateless security: every request is authenticated by the JWT access token it carries.
 */
@Configuration(proxyBeanMethods = false)
@EnableConfigurationProperties(SecurityProperties.class)
class SecurityConfiguration {

    private static final String PASSWORD_ENCODING = "argon2";

    @Bean
    SecurityFilterChain securityFilterChain(
            HttpSecurity http, @Qualifier("handlerExceptionResolver") HandlerExceptionResolver exceptionResolver) {
        // Authentication and authorization failures are rendered by the same handler as all other errors.
        AuthenticationEntryPoint entryPoint = (request, response, exception) -> {
            response.setHeader(HttpHeaders.WWW_AUTHENTICATE, "Bearer");
            exceptionResolver.resolveException(request, response, null, exception);
        };
        AccessDeniedHandler accessDeniedHandler = (request, response, exception) ->
                exceptionResolver.resolveException(request, response, null, exception);

        return http
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(requests -> requests
                        .requestMatchers(
                                "/api/v1/ping", "/api/v1/signup/**", "/api/v1/client-setup/**", "/api/v1/auth/**",
                                "/actuator/health")
                        .permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/agency/**")
                        .hasAnyRole(Role.DISPATCHER.name(), Role.ADMIN.name())
                        .requestMatchers("/api/v1/agency/**")
                        .hasRole(Role.ADMIN.name())
                        .requestMatchers(
                                "/api/v1/workers/**",
                                "/api/v1/conversations/**",
                                "/api/v1/clients/**",
                                "/api/v1/qualifications/**",
                                "/api/v1/shifts/**",
                                "/api/v1/shift-templates/**",
                                "/api/v1/hours/**")
                        .hasAnyRole(Role.DISPATCHER.name(), Role.ADMIN.name())
                        .requestMatchers("/api/v1/worker/**")
                        .hasRole(Role.WORKER.name())
                        .requestMatchers("/api/v1/client/**")
                        .hasRole(Role.CLIENT.name())
                        .anyRequest()
                        .authenticated())
                .oauth2ResourceServer(resourceServer -> resourceServer
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter()))
                        .authenticationEntryPoint(entryPoint)
                        .accessDeniedHandler(accessDeniedHandler))
                .exceptionHandling(exceptions -> exceptions
                        .authenticationEntryPoint(entryPoint)
                        .accessDeniedHandler(accessDeniedHandler))
                .addFilterAfter(new TenantFilter(), BearerTokenAuthenticationFilter.class)
                .build();
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        // Hashes carry the id of their algorithm, so it can be replaced without invalidating passwords.
        return new DelegatingPasswordEncoder(
                PASSWORD_ENCODING, Map.of(PASSWORD_ENCODING, Argon2PasswordEncoder.defaultsForSpringSecurity_v5_8()));
    }

    @Bean
    JwtEncoder jwtEncoder(SecurityProperties properties) {
        return NimbusJwtEncoder.withSecretKey(signingKey(properties)).algorithm(MacAlgorithm.HS256).build();
    }

    @Bean
    JwtDecoder jwtDecoder(SecurityProperties properties) {
        return NimbusJwtDecoder.withSecretKey(signingKey(properties)).macAlgorithm(MacAlgorithm.HS256).build();
    }

    private static JwtAuthenticationConverter jwtAuthenticationConverter() {
        var authorities = new JwtGrantedAuthoritiesConverter();
        authorities.setAuthoritiesClaimName(SessionService.ROLE_CLAIM);
        authorities.setAuthorityPrefix("ROLE_");
        var converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(authorities);
        return converter;
    }

    private static SecretKey signingKey(SecurityProperties properties) {
        return new SecretKeySpec(properties.jwtSecret().getBytes(StandardCharsets.UTF_8), "HmacSHA256");
    }
}
