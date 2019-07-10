provider "azurerm" {
    subscription_id = "e0fae348-f6c2-45f5-87b7-c41c22782d8f"
    client_id       = "51fe7006-c129-4abb-8570-7597e806221c"
    client_secret   = "_K4HVeog9k@5sW2et+cnrVpdy[Rs?7-."
    tenant_id       = "96e3cac9-1ab3-436b-9f79-2a0a4b687f1b"
}

resource "azurerm_resource_group" "myterraformgroup" {
    name     = "user03-final-rg"
    location = "koreacentral"

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "user03-fianl-vnet"
    address_space       = ["3.0.0.0/16"]
    location            = "koreasouth"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "user03-fianl-sn1"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "3.0.1.0/24"
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "user03-final-pip"
    location                     = "koreasouth"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}


resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "user03-final-sg"
    location            = "koreasouth"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

	security_rule {
        name                       = "HTTP"
        priority                   = 2001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
	
    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    name                = "user03-final-NIC"
    location            = "koreasouth"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "user03-final-Nic-conf"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }
    
    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    location            = "koreasouth"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

resource "azurerm_virtual_machine" "myterraformvm3" {
    name                  = "user03-final-VM3"
    location              = "koreasouth"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "user03-final-OsDisk3"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }
	
    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

	os_profile {
        computer_name  = "user03-final-VM3"
        admin_username = "azureuser03"
        admin_password = "SKCNC!23"
    }

	os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser03/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDISAssVDOecN6fr3nzV8wpyJMktgVpaDrxiX9NSAK37XanXuPfrXHQEhwAy0rYIk2WUPo+slxi+zTAQ0N40QsSlcK7ei/D08XYFxRfNz1xSMX65GHYtrVXzBNUhj7mmtlZTGEURbRrg0ZJiBMTAoGhn3sKNHdT/tJWRgl5aIszSTd63O7wfi8h1C8s0g6FbfQ8uTcyxkkDeW0BaVBqICILtTIjUbo3DtaLkuS0DFPCa4w0KvvmPzqq6cY2KL+BbZRZbhGDdpAhm8X2a8Jpbav7v1tYkby20CYo0mVxllSO1Xg/ACpV806w6dU8QXTyES9L066ET87Y5mlOuqH7deNp user03@cc-75306948-5fc6695478-qpqwr"
        }
    }
    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

resource "azurerm_public_ip" "myterraformpublicip2" {
    name                         = "user03-final-pip2"
    location                     = "koreasouth"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

resource "azurerm_network_interface" "myterraformnic2" {
    name                = "user03-final-NIC2"
    location            = "koreasouth"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "user03-final-Nic-conf"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip2.id}"
    }

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

resource "random_id" "randomId2" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }
    
    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount2" {
    name                = "diag${random_id.randomId2.hex}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    location            = "koreasouth"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

resource "azurerm_virtual_machine" "myterraformvm4" {
    name                  = "user03-final-VM4"
    location              = "koreasouth"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic2.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "user03-final-OsDisk4"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }
	
    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

	os_profile {
        computer_name  = "user03-final-VM4"
        admin_username = "azureuser03"
        admin_password = "SKCNC!23"
    }

	os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser03/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDISAssVDOecN6fr3nzV8wpyJMktgVpaDrxiX9NSAK37XanXuPfrXHQEhwAy0rYIk2WUPo+slxi+zTAQ0N40QsSlcK7ei/D08XYFxRfNz1xSMX65GHYtrVXzBNUhj7mmtlZTGEURbRrg0ZJiBMTAoGhn3sKNHdT/tJWRgl5aIszSTd63O7wfi8h1C8s0g6FbfQ8uTcyxkkDeW0BaVBqICILtTIjUbo3DtaLkuS0DFPCa4w0KvvmPzqq6cY2KL+BbZRZbhGDdpAhm8X2a8Jpbav7v1tYkby20CYo0mVxllSO1Xg/ACpV806w6dU8QXTyES9L066ET87Y5mlOuqH7deNp user03@cc-75306948-5fc6695478-qpqwr"
        }
    }
    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount2.primary_blob_endpoint}"
    }

    tags = {
        environment = "Terraform Uesr03 Final"
    }
}

