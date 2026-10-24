package app.shiftboard.shift;

import java.util.Collection;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;

/**
 * The shifts of the current agency as workers see them. Drafts do not exist here.
 */
public interface Shifts {

    /** The published shifts that have not started yet, earliest start first, full ones included. */
    Page<ShiftDetails> listOpen(int page, int size);

    /** A published, completed or cancelled shift. */
    Optional<ShiftDetails> find(UUID shiftId);

    /**
     * Like {@link #find}, but holds a shared lock on the shift until the transaction of the caller
     * ends, which this joins. A change of the shift, such as one that frees or takes a slot, waits
     * for that transaction, and if one was in progress, the shift is read as it left it. Readers
     * that share the lock don't wait for each other. Callers take it before they lock any
     * assignment, in the same order as every change that frees or takes a slot, so that the two
     * wait for each other instead of deadlocking.
     *
     * @throws org.springframework.transaction.IllegalTransactionStateException without a transaction
     */
    Optional<ShiftDetails> findAndLock(UUID shiftId);

    /** The shifts with these ids by id; unknown ids are left out. */
    Map<UUID, ShiftDetails> findAll(Collection<UUID> shiftIds);

    /**
     * Takes one slot of the shift for a claim and returns the shift with that slot counted. Joins
     * the transaction of the caller, so the slot is only taken if the claim is stored too.
     *
     * @throws app.shiftboard.system.ApiException {@code shift_not_found}, {@code shift_not_open},
     *         {@code shift_started} or {@code shift_full}
     * @throws org.springframework.dao.OptimisticLockingFailureException if a concurrent change of
     *         the shift won; the transaction cannot be continued
     */
    ShiftDetails claim(UUID shiftId);

    /**
     * Frees the slot of a claim that no longer holds one. Joins the transaction of the caller. A
     * shift that is no longer published keeps its count, since its slots are no longer offered.
     *
     * @throws org.springframework.dao.OptimisticLockingFailureException if a concurrent change of
     *         the shift won; the transaction cannot be continued
     */
    void release(UUID shiftId);

    /** Whether the agency has a shift with this id, drafts included. */
    boolean exists(UUID shiftId);
}
