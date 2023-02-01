import org.jenkinsci.plugins.workflow.support.steps.build.RunWrapper

def volume_size = "0"
def packer_script = "linux.pkr.hcl"
def script_base = ""
def iso_url = ""
switch(OS) {
    case "Rocky Linux 8":
        base_name = "RockyLinux-8"
        script_base = "rocky8"
        break

    case "Rocky Linux 9":
        base_name = "RockyLinux-9"
        script_base = "rocky9"
        break

    case "CentOS 7":
        base_name = "CentOS-7"
        script_base = "centos7"
        break

    case "RHEL 8":
        base_name = "RHEL-8"
        script_base = "rhel8csp"
        break

    case "RHEL 8 BYOL":
        base_name = "RHEL-8-BYOL"
        script_base = "rhel8"
        break

    case "RHEL 9":
        base_name = "RHEL-9"
        script_base = "rhel9csp"
        break

    case "RHEL 9 BYOL":
        base_name = "RHEL-9-BYOL"
        script_base = "rhel9"
        break

    case "Ubuntu 20.04":
        base_name = "Ubuntu-20.04"
        script_base = "ubuntu2004"
        break

    case "Ubuntu 22.04":
        base_name = "Ubuntu-22.04"
        script_base = "ubuntu2204"
        break

    case "Debian 11":
        base_name = "Debian-11"
        script_base = "debian11"
        break

    case "Debian 10":
        base_name = "Debian-10"
        script_base = "debian10"
        break

    case "Windows Server 2019":
        base_name = "WindowsServer-2019"
        packer_script = "windows.pkr.hcl"
        break

    case "Windows Server 2019 SQL Standard 2019":
        base_name = "WindowsServer-2019-MSSQL-Std2019"
        packer_script = "windows-sql.pkr.hcl"
        iso_url = "https://oos.eu-west-2.outscale.com/omi/iso/SW_DVD9_NTRL_SQL_Svr_Standard_Edtn_2019Dec2019_64Bit_English_OEM_VL_X22-22109.ISO"
        break

    case "Windows Server 2019 SQL Enterprise 2019":
        base_name = "WindowsServer-2019-MSSQL-Ent2019"
        packer_script = "windows-sql.pkr.hcl"
        iso_url = "https://oos.eu-west-2.outscale.com/omi/iso/SW_DVD9_NTRL_SQL_Svr_Ent_Core_2019Dec2019_64Bit_English_OEM_VL_X22-22120.ISO"
        break

    case "Windows 10":
        base_name = "Windows-10"
        packer_script = "windows.pkr.hcl"
        break
}

def source_omi = [
    "eu-west-2": "ami-5ef28d69",
    "us-east-2": "ami-604fcb3f",
    "us-west-1": "ami-12d3f3c9",
    "ap-northeast-1": "ami-e9af44fd",
    "in-west-1": "ami-44506605",
    "in-west-2": "ami-505792d1",
    "cloudgouv-eu-west-1": "ami-1e87016d",
    "top-west-1": "ami-aabb4394",
    "dv-west-1": "",
    "eng-west-1": "ami-d70cbd92"
]
def endpoint = [
    "eu-west-2": "fcu.eu-west-2.outscale.com",
    "us-east-2": "fcu.us-east-2.outscale.com",
    "us-west-1": "fcu.us-west-1.outscale.com",
    "ap-northeast-1": "fcu.ap-northeast-1.outscale.com",
    "in-west-1": "fcu.in-west-1.outscale.com",
    "in-west-2": "fcu.in-west-2.outscale.com",
    "cloudgouv-eu-west-1": "fcu.cloudgouv-eu-west-1.outscale.com",
    "top-west-1": "fcu.top-west-1.outscale.com",
    "dv-west-1": "fcu.dv-west-1.outscale.com",
    "eng-west-1": "fcu.eng-west-1.outscale.com"
]
def api_endpoint = [
    "eu-west-2": "api.eu-west-2.outscale.com",
    "us-east-2": "api.us-east-2.outscale.com",
    "us-west-1": "api.us-west-1.outscale.com",
    "ap-northeast-1": "api.ap-northeast-1.outscale.com",
    "in-west-1": "api.in-west-1.outscale.com",
    "in-west-2": "api.in-west-2.outscale.com",
    "cloudgouv-eu-west-1": "api.cloudgouv-eu-west-1.outscale.com",
    "top-west-1": "api.top-west-1.outscale.com",
    "dv-west-1": "api.dv-west-1.outscale.com",
    "eng-west-1": "api.eng-west-1.outscale.com"
]

def branches = [:]
def qa_branches = [:]
def buildLogs = [:]

for (region in REGIONS.tokenize(",")) {
    def currentRegion = region
    branches["omi_${region}"] = {
        withCredentials([usernamePassword(credentialsId: 'api_osc-omi_' + currentRegion, usernameVariable: 'OUTSCALE_ACCESSKEYID', passwordVariable: 'OUTSCALE_SECRETKEYID')]) {
            build(job: 'build-omi', parameters: [
                string(name: 'OUTSCALE_ACCESSKEYID', value: OUTSCALE_ACCESSKEYID),
                string(name: 'OUTSCALE_SECRETKEYID', value: OUTSCALE_SECRETKEYID),
                string(name: 'OUTSCALE_REGION', value: currentRegion),
                string(name: 'BASE_NAME', value: base_name),
                string(name: 'SCRIPT_BASE', value: script_base),
                string(name: 'PACKER_SCRIPT', value: packer_script),
                string(name: 'SOURCE_OMI', value: source_omi[currentRegion]),
                string(name: 'OVERRIDE_NAME', value: OVERRIDE_NAME),
                string(name: 'BRANCH', value: BRANCH),
                string(name: 'VOL_SIZE', value: volume_size),
                string(name: 'ISO_URL', value: iso_url)
            ])
        }
    }
}

stage ("build_omi") {
    parallel branches
}

if (BRANCH != 'master') {
    currentBuild.result = 'SUCCESS'
    return
}

stage ("package_list") {
    if (packer_script == 'linux.pkr.hcl') {
        node {
            for (region in REGIONS.tokenize(",")) {
                def currentRegion = region
                CUR_OMI_NAME = sh(script: "cat /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true).trim()
                PACKAGE_LIST = sh(script: "echo /usr/local/packer/logs/packages/${CUR_OMI_NAME}", returnStdout: true).trim()
                echo PACKAGE_LIST

                build(job: 'push-package', parameters: [
                    string(name: 'REGION', value: currentRegion),
                    string(name: 'BRANCH', value: base_name),
                    string(name: 'OMI_NAME', value: CUR_OMI_NAME),
                    string(name: 'PACKAGE_LIST', value: PACKAGE_LIST)
                ])
            }
        }
    }
}

stage ("omi_names") {
    node {
        for (region in REGIONS.tokenize(",")) {
            def currentRegion = region
            CUR_OMI_NAME = sh(script: "cat /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true).trim()
            CUR_OMI_IMGNAME = sh(script: "readlink -f /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true)
            echo "${currentRegion}: ${CUR_OMI_NAME} (${CUR_OMI_IMGNAME})"
        }
    }
}

for (region in REGIONS.tokenize(",")) {
    def currentRegion = region
    def currentEndpoint = api_endpoint[region]

    qa_branches["qa_${region}"] = {
        node {
            def CUR_OMI_NAME = sh(script: "cat /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true).trim()
            build(job: 'qai-omi', parameters: [
                string(name: 'OUTSCALE_REGION', value: currentRegion),
                string(name: 'TF_VAR_endpoint', value: currentEndpoint),
                string(name: 'TF_VAR_image_id', value: CUR_OMI_NAME),
                string(name: 'OS', value: base_name)
            ])
        }
    }
}

stage ("qa_omi") {
    parallel qa_branches
}

stage ("deploy_approval") {
    input "Publish OMI ?"
}

stage ("publish_omi") {
    node {
        for (region in REGIONS.tokenize(",")) {
            def currentRegion = region
            CUR_OMI_NAME = sh(script: "cat /usr/local/packer/images/${currentRegion}-${base_name}-latest", returnStdout: true).trim()

            withCredentials([usernamePassword(credentialsId: 'api_osc-omi_' + currentRegion, usernameVariable: 'OSC_ACCESS_KEY', passwordVariable: 'OSC_SECRET_KEY')]) {
                build(job: 'publish-omi', parameters: [
                    string(name: 'OSC_ACCESS_KEY', value: OSC_ACCESS_KEY),
                    string(name: 'OSC_SECRET_KEY', value: OSC_SECRET_KEY),
                    string(name: 'REGION', value: currentRegion),
                    string(name: 'OMI_ID', value: CUR_OMI_NAME),
                    string(name: 'ENDPOINT', value: endpoint[currentRegion])
                ])
            }
        }
    }
}
