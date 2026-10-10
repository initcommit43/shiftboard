package app.shiftboard.system;

import app.shiftboard.ShiftboardApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.method.HandlerTypePredicate;
import org.springframework.web.servlet.config.annotation.PathMatchConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration(proxyBeanMethods = false)
class ApiConfiguration implements WebMvcConfigurer {

    static final String API_PREFIX = "/api/v1";

    @Override
    public void configurePathMatch(PathMatchConfigurer configurer) {
        configurer.addPathPrefix(API_PREFIX, HandlerTypePredicate.forBasePackageClass(ShiftboardApplication.class)
                .and(HandlerTypePredicate.forAnnotation(RestController.class)));
    }
}
