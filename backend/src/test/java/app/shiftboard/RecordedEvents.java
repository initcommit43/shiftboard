package app.shiftboard;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import org.springframework.context.event.EventListener;

/**
 * Collects the domain events the application publishes while it handles requests.
 */
public class RecordedEvents {

    private final List<Object> events = new CopyOnWriteArrayList<>();

    @EventListener
    void record(Object event) {
        if (event.getClass().getPackageName().startsWith(ShiftboardApplication.class.getPackageName())) {
            events.add(event);
        }
    }

    public List<Object> all() {
        return List.copyOf(events);
    }
}
