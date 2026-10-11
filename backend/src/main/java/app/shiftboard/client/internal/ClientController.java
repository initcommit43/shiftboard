package app.shiftboard.client.internal;

import java.util.List;

import app.shiftboard.client.ClientDetails;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The agency's clients with their locations. Dispatchers and admins only, enforced by the
 * security configuration.
 */
@RestController
@RequestMapping("/clients")
class ClientController {

    private final ClientService clientService;

    ClientController(ClientService clientService) {
        this.clientService = clientService;
    }

    @GetMapping
    ClientPage list(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return clientService.list(page, size);
    }

    record ClientPage(List<ClientDetails> content, int page, int size, long totalElements, int totalPages) {
    }
}
