package app.shiftboard.agency.internal;

import app.shiftboard.agency.AgencyFeatures;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import tools.jackson.databind.json.JsonMapper;
import tools.jackson.databind.node.ObjectNode;

/**
 * Stores the features as a JSON object, so that a new feature needs no migration. A feature
 * missing from the stored object is off.
 */
@Converter
class FeaturesConverter implements AttributeConverter<AgencyFeatures, String> {

    private static final JsonMapper JSON = JsonMapper.builder().build();

    private static final String CONTACT_BUTTON = "contactButton";

    @Override
    public String convertToDatabaseColumn(AgencyFeatures features) {
        var json = JSON.createObjectNode();
        json.put(CONTACT_BUTTON, features.contactButton());
        return JSON.writeValueAsString(json);
    }

    @Override
    public AgencyFeatures convertToEntityAttribute(String column) {
        var defaults = AgencyFeatures.DEFAULTS;
        if (column == null || column.isBlank()) {
            return defaults;
        }
        var json = (ObjectNode) JSON.readTree(column);
        return new AgencyFeatures(json.path(CONTACT_BUTTON).asBoolean(defaults.contactButton()));
    }
}
