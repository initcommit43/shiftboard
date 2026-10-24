/** A generated enum object, with its stand-in for values this build does not know. */
type EnumObject = Readonly<Record<string, string>> & { readonly unknown_default_open_api: string }

/** The values of a generated enum that this build knows. */
export type Known<E extends EnumObject> = Exclude<E[keyof E], E['unknown_default_open_api']>

/**
 * The value if this build knows it, otherwise undefined. The API may send enum
 * values that are newer than the dashboard (ADR 0030). The generated client
 * passes them through as they are, so a lookup by value can miss even where
 * the types say it cannot: check with this first and fall back on undefined.
 */
export function known<E extends EnumObject>(enumObject: E, value: string | undefined): Known<E> | undefined {
  if (value === undefined || value === enumObject.unknown_default_open_api) {
    return undefined
  }
  return Object.values(enumObject).includes(value) ? (value as Known<E>) : undefined
}
