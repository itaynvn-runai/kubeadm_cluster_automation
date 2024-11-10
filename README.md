### Write the Terraform Script
Below is a Terraform script that creates:
-   A VPC with a public subnet.
-   Security groups to allow necessary access (SSH and Kubernetes traffic).
-   EC2 instances for a control plane and a worker node.

### Apply the Terraform Script
1.  **Initialize Terraform**: 
```
terraform init
``` 
2.  **Plan the Terraform Execution**
```
terraform plan
```
3.  **Apply the Changes**
```
terraform apply
```        
This will provision the infrastructure on AWS. After creating these EC2 instances, you can SSH into the control plane instance, initialize it as the Kubernetes control plane using `kubeadm init`, and join the worker node with `kubeadm join`.

### Prepare Ansible Inventory
Create an inventory file (`inventory.ini`) to specify the IP addresses and SSH details for the control plane and worker nodes. Replace `YOUR_CONTROL_PLANE_IP` and `YOUR_WORKER_NODE_IP` with your actual IPs:

### Ansible Playbook for Installing Kubernetes
This playbook (`k8s_cluster_setup.yaml`) will:
1.  Install necessary dependencies on both nodes.
2.  Install `kubeadm`, `kubelet`, and `kubectl`.
3.  Initialize the control plane node.
4.  Apply a networking plugin.
5.  Join the worker node to the cluster.

### Run the Playbook

Execute the playbook using the following command:
```
ansible-playbook -i inventory.ini k8s_cluster_setup.yaml
```
**Explanation of Key Steps**

-   **Install Dependencies**: Installs `curl` and sets up the Kubernetes package repository on both nodes.
-   **Initialize Control Plane**: On the control plane node, it initializes `kubeadm` with a pod network CIDR (necessary for Calico) and sets up `kubectl` configuration for the `ubuntu` user.
-   **Apply Calico CNI**: A network plugin (Calico in this case) is applied to enable pod-to-pod communication.
-   **Join Command**: The control plane generates a join command which is then used to add the worker node to the cluster.