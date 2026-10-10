package app.shiftboard.agency.internal;

import java.util.List;
import java.util.UUID;

import org.springframework.data.repository.Repository;

interface QualificationRepository extends Repository<Qualification, UUID> {

    List<Qualification> findAllByOrderByName();
}
