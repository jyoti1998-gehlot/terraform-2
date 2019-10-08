#---------------------------------------------------
# Create AWS Instance
#---------------------------------------------------
module "hulu-ami" {
    source  = "terraform.prod.hulu.com/Hulu/ami-module/aws"
    version = "0.0.7"

    name    = "hulu-base-ami-bionic-*"
}

resource "aws_instance" "instance" {
    count                       = "${var.number_of_instances}"
    
    ami                         = "${module.hulu-ami.ami_id}"
    #ami                         = "${var.ami_id}"
    #ami                         = "${var.ami_id == "" ? "${lookup(var.ami, var.region)}" : "${var.ami_id}" }"
    instance_type               = "${var.ec2_instance_type}"
    user_data                   = "${var.user_data}"
    key_name                    = "${var.key_name}"
    subnet_id                   = "${var.subnet_id}"
    vpc_security_group_ids      = ["${var.vpc_security_group_ids}"]
    monitoring                  = "${var.monitoring}"
    iam_instance_profile        = "${var.iam_instance_profile}"

    # Note: network_interface can't be specified together with associate_public_ip_address
    #network_interface           = "${var.network_interface}"
    associate_public_ip_address = "${var.enable_associate_public_ip_address}"
    private_ip                  = "${var.private_ip}"
    ipv6_address_count          = "${var.ipv6_address_count}"
    ipv6_addresses              = "${var.ipv6_addresses}"

    source_dest_check                    = "${var.source_dest_check}"
    disable_api_termination              = "${var.disable_api_termination}"
    instance_initiated_shutdown_behavior = "${var.instance_initiated_shutdown_behavior}"
    placement_group                      = "${var.placement_group}"
    tenancy                              = "${var.tenancy}"

    ebs_optimized          = "${var.ebs_optimized}"
    volume_tags            = "${var.volume_tags}"
    root_block_device {
        volume_size = "${var.disk_size}"
    #    volume_type = "gp2"
    }
    ebs_block_device       = "${var.ebs_block_device}"
    ephemeral_block_device = "${var.ephemeral_block_device}"

    lifecycle {
        create_before_destroy = true
        # Due to several known issues in Terraform AWS provider related to arguments of aws_instance:
        # (eg, https://github.com/terraform-providers/terraform-provider-aws/issues/2036)
        # we have to ignore changes in the following arguments
        ignore_changes = ["private_ip", "vpc_security_group_ids", "root_block_device", "subnet_id"]
    }
    
    tags {
        Name            = "${lower(var.name)}-ec2-${lower(var.environment)}-${count.index+1}"
        Environment     = "${var.environment}"
        Orchestration   = "${var.orchestration}"
        Createdby       = "${var.createdby}"
        YP_Service_ID   = "${var.yp_service_id}"
        YP_Team_ID      = "${var.yp_team_id}"
        Garage_Group_ID = "${var.garage_group_id}"
    }
#    ##############################################
#    # Provisioning
#    #############################################
#    provisioner "remote-exec" {
#        inline = [
#            "sudo yum update -y",
#            "sudo yum upgrade -y",
#            "uname -a"
#        ]
#        connection {
#            #host        = "${element(aws_instance.instance.*.public_ip, 0)}"
#            user        = "centos"
#            #password   = ""
#            timeout     = "5m"
#            private_key = "${file("${var.private_key}")}"
#            agent       = "true"
#            type        = "ssh"
#        }
#    }
    
    depends_on = []
}
