{
  lib,
  fetchRocmSrc,
  sources,
  gitUpdater,
  buildPythonPackage,
  setuptools,
  beautifulsoup4,
  gitpython,
  pydata-sphinx-theme,
  pygithub,
  sphinx,
  breathe,
  myst-nb,
  myst-parser,
  sphinx-book-theme,
  sphinx-copybutton,
  sphinx-design,
  sphinx-external-toc,
  sphinx-notfound-page,
  pyyaml,
  fastjsonschema,
}:

# FIXME: Move to rocmPackages_common
buildPythonPackage (finalAttrs: {
  pname = "rocm-docs-core";
  version = sources.rocm-docs-core.version;
  pyproject = true;

  src = fetchRocmSrc "rocm-docs-core";

  buildInputs = [ setuptools ];

  propagatedBuildInputs = [
    beautifulsoup4
    gitpython
    pydata-sphinx-theme
    pygithub
    sphinx
    breathe
    myst-nb
    myst-parser
    sphinx-book-theme
    sphinx-copybutton
    sphinx-design
    sphinx-external-toc
    sphinx-notfound-page
    pyyaml
    fastjsonschema
  ];

  pythonImportsCheck = [ "rocm_docs" ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "ROCm Documentation Python package for ReadTheDocs build standardization";
    homepage = "https://github.com/ROCm/rocm-docs-core";
    license = with lib.licenses; [
      mit
      cc-by-40
    ];
    teams = [ lib.teams.rocm ];
    platforms = lib.platforms.linux;
  };
})
