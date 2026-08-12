# Drupal Final Project – Nikita Koyfman

## a. Who I Am

My name is Nikita Koyfman, and I am a student in the Development Tools course at Afeka College.

## b. What I Was Required to Do

My part of the project included:

* **Part 2 – Drupal Configuration**
* **Part 3 – Running Drupal and Creating Initial Content**

For these parts I had to configure Drupal on a Linux machine, connect Drupal to a PostgreSQL database running in a separate Docker container, complete the Drupal website configuration, verify that the website works and create the initial glossary content.

## c. What I Did

I configured and ran Drupal on a Linux machine using Docker.

I used a `compose.yaml` file to run Drupal and PostgreSQL in two separate containers and connected them through a shared Docker network.

I configured Drupal to use the PostgreSQL database and completed the website installation.

After the installation I created a new Drupal Content Type called `Glossary Entry`, added a `Definition` field and added the glossary terms to the website.

I also checked that the website was working correctly and verified that Drupal had saved the PostgreSQL connection correctly.

## d. Technologies I Used

* Linux Ubuntu
* Docker
* Docker Compose
* Drupal
* PostgreSQL
* Git
* GitHub

# e. Step-by-Step Guide

The following steps explain how I created and configured my part of the project on a **Linux Ubuntu machine**.

## 1. Install the Required Software

Before starting the project, install the required software on the Linux machine:

* Git
* Docker
* Docker Compose

After the software is installed, continue with the following steps.

## 2. Clone the Repository

Open the Linux Terminal and clone the project repository:

```bash
git clone https://github.com/orenlevi6/devtools-course-assignment.git
```

Enter the project directory:

```bash
cd devtools-course-assignment
```

## 3. Check Docker

Check that Docker and Docker Compose are installed and working:

```bash
docker --version
docker compose version
docker ps
```

The versions can be different depending on the Linux machine.

In my case, I received:

```text
Docker version 28.0.4, build b8034c0
Docker Compose version v2.34.0
```

## 4. Create the `compose.yaml` File

Inside the project directory, open a new file:

```bash
nano compose.yaml
```

Inside the file define two containers:

* PostgreSQL – the database used by Drupal.
* Drupal – the content management system.

Also define a shared Docker network and two Volumes.

```yaml
services:
  postgres:
    image: postgres:latest
    container_name: drupal-postgres
    environment:
      POSTGRES_DB: drupal_db
      POSTGRES_USER: drupal_user
      POSTGRES_PASSWORD: my-secret-pw
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql
    networks:
      - drupal_network

  drupal:
    image: drupal:latest
    container_name: drupal-app
    depends_on:
      - postgres
    ports:
      - "8080:80"
    volumes:
      - drupal_data:/var/www/html
    networks:
      - drupal_network

networks:
  drupal_network:

volumes:
  postgres_data:
  drupal_data:
```

PostgreSQL uses port `5432`.

Drupal uses port `8080` on the Linux machine, which is mapped to port `80` inside the Drupal container.

Both containers are connected to the same `drupal_network`. This allows Drupal to communicate with PostgreSQL.

After pasting the configuration into Nano:

1. Press `Ctrl + O` to save.
2. Press `Enter` to confirm the file name.
3. Press `Ctrl + X` to return to the Terminal.

## 5. Start PostgreSQL and Drupal

Run:

```bash
docker compose up -d
```

This command reads the configuration from `compose.yaml`, downloads the PostgreSQL and Drupal Images and starts the Docker environment.

It creates:

* `drupal-postgres`
* `drupal-app`
* A shared network
* A PostgreSQL Volume
* A Drupal Volume

## 6. Check the Running Containers

Run:

```bash
docker ps
```

Check that both containers are running.

The result should include:

```text
drupal-app:       0.0.0.0:8080->80/tcp
drupal-postgres:  0.0.0.0:5432->5432/tcp
```

This shows that Drupal is available through port `8080` and PostgreSQL through port `5432`.

## 7. Check the Docker Network

Run:

```bash
docker network ls
```

In my setup the shared network was:

```text
devtools_drupal_network
```

Then inspect the network:

```bash
docker network inspect devtools_drupal_network
```

Both `drupal-postgres` and `drupal-app` should appear inside the network.

In my setup:

```text
drupal-postgres: 172.18.0.2
drupal-app:      172.18.0.3
```

This verifies that Drupal and PostgreSQL run in separate containers and can communicate through the shared Docker network.

## 8. Check the Docker Images

Run:

```bash
docker compose pull
```

Then run:

```bash
docker compose up -d
```

This makes sure that the PostgreSQL and Drupal containers are running with the updated Images.

## 9. Check PostgreSQL

Check that PostgreSQL is running:

```bash
docker exec drupal-postgres pg_isready -U drupal_user -d drupal_db
```

The expected result is:

```text
/var/run/postgresql:5432 - accepting connections
```

The `accepting connections` message shows that PostgreSQL is running and ready to accept connections.

## 10. Check Drupal

Check that Drupal is accessible through port `8080`:

```bash
curl -I http://localhost:8080
```

In my setup, I received:

```text
HTTP/1.1 302 Found
```

This shows that the Drupal server is responding.

## 11. Open Drupal in the Linux Browser

Open the browser inside the Linux machine and go to:

```text
http://localhost:8080
```

Select English or Hebrew  and begin the Drupal installation.

## 12. Connect Drupal to PostgreSQL

During the Drupal database setup configure the connection as follows:

```text
Database type: PostgreSQL
Database name: drupal_db
Database username: drupal_user
Database password: my-secret-pw
Host: drupal-postgres
Port: 5432
```

Drupal uses `drupal-postgres` as the Host because this is the name of the PostgreSQL container defined in `compose.yaml`.

## 13. Configure the Drupal Website

Configure the website name using the names of the team members and enter the Site email address.

Create the administrator account:

```text
Username: demoadmin
Password: secretpass
```

Complete the Drupal installation.

## 14. Check the Website

After the installation is complete open:

```text
http://localhost:8080
```

Log in using the `demoadmin` account.

Check that:

* The homepage opens correctly.
* The website name appears.
* The logged-in username appears.
* The Drupal administration screens can be opened.

## 15. Verify the PostgreSQL Connection

Check the database configuration saved by Drupal:

```bash
docker exec drupal-app php -r '
include "/var/www/html/sites/default/settings.php";
$d=$databases["default"]["default"];
echo "database=".$d["database"].PHP_EOL;
echo "username=".$d["username"].PHP_EOL;
echo "host=".$d["host"].PHP_EOL;
echo "port=".$d["port"].PHP_EOL;
echo "driver=".$d["driver"].PHP_EOL;
'
```

The output should be:

```text
database=drupal_db
username=drupal_user
host=drupal-postgres
port=5432
driver=pgsql
```

The value:

```text
driver=pgsql
```

confirms that Drupal is connected to PostgreSQL.

# Part 3 – Running Drupal and Creating Initial Content

## 16. Create the `Glossary Entry` Content Type

Inside Drupal open the Content management screen and create a new Content Type named:

```text
Glossary Entry
```

Configure it as follows:

```text
Description: An entry from the Development Tools course glossary.
Title field label: Term
```

## 17. Configure the Publishing Options

Configure the publishing options for `Glossary Entry`:

```text
Published: enabled
Create new revision: enabled
```

Keep the other publishing options disabled.

## 18. Add the `Definition` Field

Add a new field named `Definition`.

Configure it as follows:

```text
Label: Definition
Machine name: field_definition
Field type: Long text
Allowed number of values: 1
Required field: enabled
Allowed text format: Basic HTML
```

## 19. Add the Glossary Content

For every glossary term go to:

```text
Content -> Add content -> Glossary Entry
```

For each entry:

* Enter the name of the concept in the `Term` field.
* Enter its explanation and example in the `Definition` field.

## 20. Check the Created Content

Return to the Drupal Content screen.

Check that:

* All glossary terms appear.
* Every entry is in `Published` status.
* Every entry opens correctly.

This completes the Drupal configuration and the creation of the initial content for Parts 2 and 3 of the project.

