package app.shiftboard.identity;

/**
 * How workers reach a dispatcher or admin: the name and, if there is one on record, the phone number.
 */
public record StaffContact(String name, String phone) {
}
