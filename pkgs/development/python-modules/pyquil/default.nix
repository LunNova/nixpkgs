{
  lib,
  buildPythonPackage,
  deprecated,
  fetchFromGitHub,
  ipython,
  matplotlib-inline,
  nest-asyncio,
  networkx,
  numpy,
  packaging,
  poetry-core,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  pythonOlder,
  qcs-sdk-python,
  respx,
  rpcq,
  scipy,
  syrupy,
  types-deprecated,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pyquil";
  version = "4.15.0";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = "pyquil";
    tag = "v${version}";
    hash = "sha256-zRXIMSgcFlTZQ5Y/1pSC30ZhvKj1Pn1+7SbTetEdzio=";
  };

  pythonRelaxDeps = [
    "lark"
    "networkx"
    "packaging"
    "qcs-sdk-python"
    "rpcq"
  ];

  build-system = [ poetry-core ];

  dependencies = [
    deprecated
    matplotlib-inline
    networkx
    numpy
    packaging
    qcs-sdk-python
    rpcq
    scipy
    types-deprecated
    typing-extensions
  ];

  nativeCheckInputs = [
    nest-asyncio
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    respx
    syrupy
    ipython
  ];

  # tests hang
  doCheck = false;

  pythonImportsCheck = [ "pyquil" ];

  meta = with lib; {
    description = "Python library for creating Quantum Instruction Language (Quil) programs";
    homepage = "https://github.com/rigetti/pyquil";
    changelog = "https://github.com/rigetti/pyquil/blob/v${version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
