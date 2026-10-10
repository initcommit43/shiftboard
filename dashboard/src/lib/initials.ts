/** Up to two initials: "Lena Hofer" → "LH", "anna.berger" → "AB". */
export function initials(name: string) {
  return name
    .split(/[\s._-]+/)
    .slice(0, 2)
    .map((part) => part.charAt(0))
    .join('')
    .toUpperCase()
}
