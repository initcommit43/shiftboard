package app.shiftboard.agency.internal;

import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.Repository;

interface QualificationRepository extends Repository<Qualification, UUID> {

    Page<Qualification> findAll(Pageable pageable);

    List<Qualification> findAllByOrderByName();
}
