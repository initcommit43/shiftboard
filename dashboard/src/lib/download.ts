/** Hands the browser a file to save under the given name. */
export function downloadFile(name: string, content: string, type: string) {
  const url = URL.createObjectURL(new Blob([content], { type }))
  const link = document.createElement('a')
  link.href = url
  link.download = name
  document.body.append(link)
  link.click()
  link.remove()
  // Some browsers start the download only after the click has been handled.
  setTimeout(() => {
    URL.revokeObjectURL(url)
  }, 0)
}
