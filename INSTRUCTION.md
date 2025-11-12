## Setup and Deployment

The bootstrap.sh script contains all the commands to create the cluster and deploy the infrastructure.

Run the following commands to initialize the KinD cluster and deploy all resources.

```bash
./bootstrap.sh
```

## Verify Resource Status

Check the status of all resources in the dedicated namespaces.

```bash
# Check the MySQL database resources (StatefulSet, Service, Pods)
kubectl get all -n mysql
kubectl get pvc -n mysql
kubectl get statefulset -n mysql

# Check the Application resources (Deployment, Service, Pods)
kubectl get all -n todoapp
```

Expected result:

All pods (e.g., mysql-0, mysql-1, mysql-2, and the application pod) should be in the Running state.
All Persistent Volume Claims (pvc) in the mysql namespace should be Bound.

## Database Validation

The primary goal is to ensure the application can connect to mysql-0 and that the init.sql script ran successfully.

1. Validate Initial Data Setup
   We will connect to the primary database pod (mysql-0) and check for the lists_todo table created by the init.sql
   script.

a. Run the MySQL client inside the cluster:

```bash
# This command runs a temporary pod with the mysql client image in the 'mysql' namespace.
kubectl run mysql-client --image=mysql:8.0 -it -n mysql -- /bin/sh
```

b. Execute the validation query:

Once inside the temporary shell (the command prompt will change), use the following command to connect to the primary
pod using its stable DNS name (mysql-0.mysql) and verify the table exists.

(Replace 1234 with the actual root password from your Secret)

```bash
# Inside the temporary pod's shell:
mysql -h mysql-0.mysql -u root --password=1234 -e "SHOW TABLES FROM app_db;"
```

✅ Expected output:

+------------------+
| Tables_in_app_db |
+------------------+
| lists_todo |
+------------------+
(Type exit to leave the MySQL client, and then exit again to leave the temporary pod's shell.)

2. Validate init.sql Mount
   We will confirm that the init.sql script was successfully mounted into the correct directory on the database pod.

Connect to the primary MySQL pod:

```bash
kubectl -n mysql exec -it mysql-0 -- sh
```

List files in the initialization directory:

```bash
ls /docker-entrypoint-initdb.d
```

✅ Expected output:

```text
init.sql
```

Exit the pod:

```bash
exit
```

## 🌐 Application Connectivity Validation

We confirm that the application is successfully reading its secret credentials and connecting to the database.

1. Check Application Startup Logs

The initContainer running the database migration must have completed successfully.

```bash
# Find the name of your application pod
kubectl get pods -n todoapp 

# Check the logs of the main application container (it would fail if the DB connection failed)
kubectl logs -f <todoapp-pod-name> -n todoapp
```

✅ Expected result: The application container logs show a successful startup message (e.g., Django server started)
and no django.db.utils.OperationalError.

2. Validate Application Access

Forward the application service port to your local machine and test access.

```bash
# Forward the ClusterIP service for testing
kubectl port-forward svc/todoapp-service 8081:80 -n todoapp
```

In a separate terminal:

```bash
curl localhost:8081
```

✅ Expected result: Application home page or API response is returned, confirming the application layer 
is functional and connected to the database.

## 🧹 Cleanup
When finished, delete the entire KinD cluster to clean up all resources (pods, services, volumes, etc.).

```bash
kind delete cluster --name todoapp-cluster
```
