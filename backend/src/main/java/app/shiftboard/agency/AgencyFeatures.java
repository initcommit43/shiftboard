package app.shiftboard.agency;

/**
 * The optional features an agency has switched on.
 *
 * @param contactButton workers see a WhatsApp button for the contact person of a shift
 * @param checkIn       workers check in and out of their shifts in the app (ADR 0028)
 * @param clientPortal  the staff of the agency's clients log in to see their shifts (ADR 0032)
 */
public record AgencyFeatures(boolean contactButton, boolean checkIn, boolean clientPortal) {

    /** Everything optional is off. */
    public static final AgencyFeatures DEFAULTS = new AgencyFeatures(false, false, false);
}
