## 0.5.0 (2020-07-02)

 - [TT-7683] Add support for AWS SSM and AWS Secrets Manager

## 0.4.0 (2020-05-20)

 - [TT-7323] Bring all dependencies up to date

## 0.3.0 (2017-07-31)

Removed:
 - [TT-2967] Remove deprecated `Yamload::Loader#loaded_hash`
 - [TT-2967] Remove schema validation

Changed:
 - [TT-1790] Update ClassyHash to version 0.2.0

## 0.2.0 (2015-02-20)

Features:

  - Add ERB parsing as a prestep for loaded YAML files

## 0.1.0 (2015-02-17)

  - use proper semantic versioning (semver.org)

Features:

  - support loading valid yml files which don't define a hash
  - deprecates `Yamload::Loader#loaded_hash` in favour of `Yamload::Loader#content`

## 0.0.6 (2015-02-04)

Bugfixes:

  - check for directory existence

## 0.0.5 (2015-02-04)

Bugfixes:

  - check for file existence
  - check for validity of file contents

## 0.0.4 (2015-02-04)

Features:

  - implement `Yamload::Loader#exist?` to check for file presence

## 0.0.3 (2015-02-04)

Features:

  - use a faster schema validation engine with no dependencies

## 0.0.2 (2015-02-04)

Features:

  - freeze the loaded hash

## 0.0.1 (2015-02-04)

Features:

  - load valid yml files defining a hash
  - conversion of loaded hash to immutable object
  - default values
  - schema validation
