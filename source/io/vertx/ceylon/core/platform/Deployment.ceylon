"Manage a deployment"
shared class Deployment(
    "The deployemnt id"
    shared String id, Anything(String) undeployer) {
    
    "Undeploy the deployment"
    shared void undeploy() {
        undeployer(id);
    }
}