# DITA-OT Unit-Test GitHub action [<img src="https://jason-fox.github.io/fox.jason.unit-test/unit.png" align="right" width="300">](https://unit-test-framework-for-dita-ot.rtfd.io)

This action installs and instruments a DITA-OT Plugin and then runs a supplied suite of tests across the DITA-OT plugin to provide Code Coverage and Unit Test Results.

## Inputs

### `dita-ot-version`

The version of DITA-OT to use. Defaults to `4.1.1`

### `plugin`

**Required** The name of the DITA-OT plugin to install and test.

### `setup-script`

The name of a bash script to run to install any dependencies prior to run the test. Defaults to `test-setup.sh` if not supplied.

### `prerequisites`

Comma separated list of additional DITA-OT plugins to install prior to installing the plugin under test.

### `plugin`

**Required** The name of the DITA-OT plugin to install and test.

if `COVERALLS_TOKEN` is added as an ENV, coverage results are pushed to [Coveralls](https://coveralls.io/).

## Example usage

```yaml
uses: jason-fox/dita-unit-test-action@master
with:
    dita-ot-version: 3.7.2
    plugin: 'fox.jason.prismjs'
    setup-script: 'startup.sh'
    prerequisites: 'org.doctales.xmltask,fox.jason.extend.css'
env:
    COVERALLS_TOKEN: ${{ secrets.COVERALLS_TOKEN }}
```

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE)
