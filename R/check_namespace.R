#' Read a package NAMESPACE and check for dangerous imports
#'
#' Given a path to a package source tree, return a list of Imports (both whole
#' packages and fully qualified references).
#'
#' @md
#' @param pkg_path path to package source tree
#' @param dangerous_imports character vector of dangerous items to find
#' @export
#' @examples \dontrun{
#' check_namespace("../testevil", c("processx", "sys", "processx::run"))
#' }
check_namespace <- function(pkg_path, dangerous_imports = character(0)) {

  assert_path_exists(pkg_path)
  assert_is_package(pkg_path)

  imports_list <- parse_ns_file(pkg_path)$imports

  whole_pkg_imports <- extract_whole_pkg_imports(imports_list)
  fqrs <- extract_fully_qualified_references(imports_list)

  imported_packages <- c(
    whole_pkg_imports,
    extract_pkgs_from_fully_qualified_references(fqrs)
  ) %>%
    unique()
  imported_functions <- transform_fully_qualified_refereces(fqrs)


  all_imports <- c(imported_packages, imported_functions)

  all_imports[all_imports %in% dangerous_imports]
}

parse_ns_file <- function(pkg_path) {
  parseNamespaceFile(
    basename(pkg_path), dirname(pkg_path), mustExist = FALSE
  )
}

extract_whole_pkg_imports <- function(imports) {
  unlist(imports[lengths(imports) == 1], use.names = FALSE)
}

extract_fully_qualified_references <- function(imports) {
  imports[(lengths(imports) == 2)]
}

extract_pkgs_from_fully_qualified_references <- function(fqrs) {
  sapply(fqrs, function(x) x[[1]])
}

transform_fully_qualified_refereces <- function(fqrs) {
  sapply(fqrs, function(x) {
    sprintf("%s::%s", x[[1]], x[[2]])
  })
}