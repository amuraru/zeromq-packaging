
## Centos 5 only
###Required packages

```bash
yum groupinstall "Development tools"
yum install asciidoc xmlto
```

### Man generation
If you cannot generate man pages then a dirty fix is to
edit /usr/bin/xmlto and disable default validation

Set `SKIP_VALIDATION=1`

