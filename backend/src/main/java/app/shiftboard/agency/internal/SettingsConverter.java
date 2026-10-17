package app.shiftboard.agency.internal;

import app.shiftboard.agency.AgencySettings;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import tools.jackson.databind.json.JsonMapper;
import tools.jackson.databind.node.ObjectNode;

/**
 * Stores the settings as a JSON object, so that a new setting needs no migration. A setting
 * missing from the stored object has its default value.
 */
@Converter
class SettingsConverter implements AttributeConverter<AgencySettings, String> {

    private static final JsonMapper JSON = JsonMapper.builder().build();

    private static final String AUTO_CONFIRM = "autoConfirm";

    private static final String CANCELLATION_DEADLINE_HOURS = "cancellationDeadlineHours";

    @Override
    public String convertToDatabaseColumn(AgencySettings settings) {
        var json = JSON.createObjectNode();
        json.put(AUTO_CONFIRM, settings.autoConfirm());
        json.put(CANCELLATION_DEADLINE_HOURS, settings.cancellationDeadlineHours());
        return JSON.writeValueAsString(json);
    }

    @Override
    public AgencySettings convertToEntityAttribute(String column) {
        var defaults = AgencySettings.DEFAULTS;
        if (column == null || column.isBlank()) {
            return defaults;
        }
        var json = (ObjectNode) JSON.readTree(column);
        return new AgencySettings(
                json.path(AUTO_CONFIRM).asBoolean(defaults.autoConfirm()),
                json.path(CANCELLATION_DEADLINE_HOURS).asInt(defaults.cancellationDeadlineHours()));
    }
}
