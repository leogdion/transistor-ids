
protocol XMLParsingListener {
  var result : Result<[RssItem], Error> { get }
}
