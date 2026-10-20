package app.shiftboard.shift.internal;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.Repository;

interface ShiftTemplateRepository extends Repository<ShiftTemplate, UUID> {

    /** Writes the template right away, so that a name taken at the same moment fails here. */
    ShiftTemplate saveAndFlush(ShiftTemplate template);

    Page<ShiftTemplate> findAll(Pageable pageable);

    Optional<ShiftTemplate> findById(UUID id);

    boolean existsByNameIgnoreCase(String name);

    boolean existsByNameIgnoreCaseAndIdNot(String name, UUID id);

    void delete(ShiftTemplate template);
}
