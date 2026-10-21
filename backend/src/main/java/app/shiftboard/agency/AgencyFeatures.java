package app.shiftboard.agency;

/**
 * The optional features an agency has switched on.
 *
 * @param contactButton workers see a WhatsApp button for the contact person of a shift
 */
public record AgencyFeatures(boolean contactButton) {

    /** Everything optional is off. */
    public static final AgencyFeatures DEFAULTS = new AgencyFeatures(false);
}
