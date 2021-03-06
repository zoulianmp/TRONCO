#### estimate.tree.probs.R
####
#### TRONCO: a tool for TRanslational ONCOlogy
####
#### See the files COPYING and LICENSE for copyright and licensing
#### information.


#estimate the marginal, joint and conditional probabilities given the reconstructed topology and the error rates
#INPUT:
#marginal.probs: observed marginal probabilities
#joint.probs: observed joint probabilities
#parents.pos: position of the parents in the list of nodes
#error.rates: rates for the false positive and the false negative errors
#RETURN:
#estimated.probs: estimated marginal, joint and conditional probabilities
"estimate.tree.probs" <-
function(marginal.probs,joint.probs,parents.pos,error.rates) {
    #structure where to save the probabilities to be estimated
    estimated.marginal.probs = array(-1, dim=c(nrow(marginal.probs),1));
    estimated.joint.probs = array(-1, dim=c(nrow(marginal.probs),nrow(marginal.probs)));
    estimated.conditional.probs = array(-1, dim=c(nrow(marginal.probs),1));
    #estimate the theoretical conditional probabilities given the error rates
    #this estimation is performed by applying the error rates to the marginal and joint probabilities
    theoretical.conditional.probs = array(-1, dim=c(nrow(marginal.probs),1));
    for (i in 1:nrow(theoretical.conditional.probs)) {
        #if the node has a parent, use the error rates to compute the conditional probability
        #if the node has no parent, its conditional probability is not considered
        if(parents.pos[i,1]!=-1) {
            #P(i|j)_theoretical = ((P(i,j)_obs-e_p*(P(j)_obs+P(i)_obs)+e_p^2)/(1-e_n-e_p)^2)/((P(j)_obs-e_p)/(1-e_n-e_p))
            theoretical.conditional.probs[i,1] = (joint.probs[i,parents.pos[i,1]]-error.rates$error.fp*(marginal.probs[parents.pos[i,1],1]+marginal.probs[i,1])+error.rates$error.fp^2)/((marginal.probs[parents.pos[i,1],1]-error.rates$error.fp)*(1-error.rates$error.fn-error.rates$error.fp));
            if(theoretical.conditional.probs[i,1]<0 || theoretical.conditional.probs[i,1]>1) {
                #invalid theoretical conditional probability
                if(theoretical.conditional.probs[i,1]<0) {
                    theoretical.conditional.probs[i,1] = 0;
                }
                else {
                    theoretical.conditional.probs[i,1] = 1;
                }
            }
        }
    }
    #estimate the marginal observed probabilities
    #this estimation is performed by applying the topological constraints on the probabilities and then the error rates
    #I do not have any constraint on the nodes without a parent
    child.list <- which(parents.pos==-1);
    estimated.marginal.probs[child.list,1] = marginal.probs[child.list,1];
    estimated.marginal.probs.with.error = array(-1, dim=c(nrow(marginal.probs),1));
    estimated.marginal.probs.with.error[child.list,1] = estimated.marginal.probs[child.list,1];
    visited = length(child.list);
    #I do not have any constraint for the joint probabilities on the pair of nodes which are the roots of the tree/forest
    estimated.joint = array(0, dim=c(nrow(marginal.probs),nrow(marginal.probs)));
    for (i in child.list) {
        for (j in child.list) {
            if(i!=j) {
                estimated.joint.probs[i,j] = joint.probs[i,j];
                estimated.joint[i,j] = -1;
            }
        }
    }
    #visit the nodes with a parent in topological order
    while (visited < nrow(estimated.marginal.probs)) {
        #set the new child list
        new.child = vector();
        #go through the current parents
        for (node in child.list) {
            #set the new children
            curr.child <- which(parents.pos==node);
            #go through the current children
            for (child in curr.child) {
                #set the marginal probability for this node
                #P(child)_estimate = P(parent)_estimate * P(child|parent)_theoretical
                estimated.marginal.probs[child,1] = estimated.marginal.probs[parents.pos[child,1],1]*theoretical.conditional.probs[child,1];
                visited = visited + 1;
                #P(child,parent)_estimare = P(child)_estimate;
                estimated.joint.probs[child,parents.pos[child,1]] = estimated.marginal.probs[child,1];
                estimated.joint[child,parents.pos[child,1]] = 1;
                estimated.joint.probs[parents.pos[child,1],child] = estimated.marginal.probs[child,1];
                estimated.joint[parents.pos[child,1],child] = 1;
                #apply the error rates to the marginal probabilities
                #P(i)_obs_estimate = P(i)_estimate*(1-e_n) + P(not i)_estimate*e_p
                estimated.marginal.probs.with.error[child,1] = error.rates$error.fp+(1-error.rates$error.fn-error.rates$error.fp)*estimated.marginal.probs[child,1];
                if(estimated.marginal.probs.with.error[child,1]<0 || estimated.marginal.probs.with.error[child,1]>1) {
                    #invalid estimated observed probability
                    if(estimated.marginal.probs.with.error[child,1]<0) {
                        estimated.marginal.probs.with.error[child,1] = 0;
                    }
                    else {
                        estimated.marginal.probs.with.error[child,1] = 1;
                    }
                }
            }
            new.child <- c(new.child,curr.child);
        }
        #set the next child list
        child.list = new.child;
    }
    diag(estimated.joint.probs) = estimated.marginal.probs;
    diag(estimated.joint) = -1;
    #given the estimated observed probabilities, I can now also estimate the joint probabilities by applying the topological constraints and then the error rates
    for (i in 1:nrow(estimated.joint.probs)) {
        for (j in i:nrow(estimated.joint.probs)) {
            #if I still need to estimate this joint probability
            if(estimated.joint[i,j]==0) {
                estimated.joint.probs[i,j] = estimate.tree.joint.probs(i,j,parents.pos,estimated.marginal.probs,theoretical.conditional.probs);
                estimated.joint[i,j] = 1;
            }
            #now I can apply the error rates to estimate the observed joint probabilities
            if(estimated.joint[i,j]==1) {
                #P(i,j)_obs_estimate = P(i,j)_estimate*(1-e_n)^2+P(not i,j)_estimate*e_p*(1-e_n)+P(i,not j)_estimate*(1-e_n)*e_p+P(not i,not j)_estimate*e_p^2;
                estimated.joint.probs[i,j] = estimated.joint.probs[i,j]*((1-error.rates$error.fn-error.rates$error.fp)^2)+error.rates$error.fp*(estimated.marginal.probs[i,1]+estimated.marginal.probs[j,1])-error.rates$error.fp^2;
                #invalid estimated joint probability
                if(estimated.joint.probs[i,j]<0 || estimated.joint.probs[i,j]>min(estimated.marginal.probs.with.error[i,1],estimated.marginal.probs.with.error[j,1])) {
                    if(estimated.joint.probs[i,j]<0) {
                        estimated.joint.probs[i,j] = 0;
                    }
                    else {
                        estimated.joint.probs[i,j] = min(estimated.marginal.probs.with.error[i,1],estimated.marginal.probs.with.error[j,1]);
                    }
                }
                estimated.joint.probs[j,i] = estimated.joint.probs[i,j];
            }
        }
    }
    #save the estimated probabilities
    estimated.marginal.probs = estimated.marginal.probs.with.error;
    #given the estimated observed and joint probabilities, I can finally compute the conditional probabilities
    #P(child|parent)_obs_estimate = P(parent,child)_obs_estimate/P(parent)_obs_estimate
    for (i in 1:nrow(estimated.conditional.probs)) {
        if(parents.pos[i,1]!=-1) {
            if(estimated.marginal.probs[parents.pos[i,1],1]>0) {
                estimated.conditional.probs[i,1] = estimated.joint.probs[parents.pos[i,1],i]/estimated.marginal.probs[parents.pos[i,1],1];
            }
            else {
                estimated.conditional.probs[i,1] = 0;
            }
        }
        #if the node has no parent, its conditional probability is set to 1
        else {
            estimated.conditional.probs[i,1] = 1;
        }
    }
    #structure to save the results
    estimated.probs = list(marginal.probs=estimated.marginal.probs,joint.probs=estimated.joint.probs,conditional.probs=estimated.conditional.probs);
    return(estimated.probs);
}

#### end of file -- estimate.tree.probs.R
