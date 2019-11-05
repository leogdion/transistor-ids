
enum RssParserError : Error {
  case missingFieldName(String)
  case invalidEndTag(String)
  case invalidContentForElementName(String, Error)
}
