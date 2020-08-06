Had to adjust meta-altera push by hand due to 
backing a commit out of meta-altera.

sha=d6f1376
br=angstrom-v2014.12-yocto1.7
tag=rel_angstrom-v2014.12-yocto1.7_16.09.02_pr

echo "git tag -f $tag $sha"
echo "git push -f origin :$tag"
echo "git push -f origin $tag"
echo "git push -f portal $tag"
echo "git push -f portal $tag:refs/heads/$br"

atull@linuxheads99:~/repos/internal/meta-altera$ git push -f origin rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
\033[1;31m###############################################################
###############################################################
This system is for the use of Altera authorized users only.  
Individuals using this computing system without authority, or
in excess of their authority, are subject to having all of   
their activities on this system monitored and recorded by the
system personnel.                                            
In the course of monitoring individuals improperly using this
system, or in the course of system maintenance, the activities
of authorized users may be monitored.  Anyone using this 
system expressly consents to such monitoring and is advised 
that if such monitoring reveals possible evidence of criminal 
activity, system personnel may provide the evidence of such 
monitoring to law enforcement officials.
###############################################################
###############################################################\033[0m
Total 0 (delta 0), reused 0 (delta 0)
remote: testing
remote: /usr/local/git/repositories/meta-altera.git
remote: update_safe refs/tags/rel_angstrom-v2014.12-yocto1.7_16.09.02_pr cdd748a29b91ab8adb13b6c3df883854388258a5 d6f1376455ff9341a67e44bbcb0253d5e78883a4
remote: 
remote:  ***********************************************************************************************
remote:  *** If you have problems with a git push, please send this whole log along with the patches ***
remote:  *** you are trying to push to Alan and Yves (atull@altera.com and yvanderv@altera.com)      ***
remote:  ***                                                                                         ***
remote:  *** Common mistakes: doing 'git-pull', 'git-merge', or pushing to a branch without first    ***
remote:  *** updating (git fetch origin && git rebase)                                               ***
remote:  ***                                                                                         ***
remote:  *** see also:                                                                               ***
remote:  *** linux-socfpga/Documentation/CodingStyle                                                 ***
remote:  *** http://sw-wiki.altera.com/twiki/bin/view/Software/HPSLinuxDevelopmentFlow               ***
remote:  *** http://sw-wiki.altera.com/twiki/bin/view/Software/HPSLinuxGITQuickIntroduction          ***
remote:  ***********************************************************************************************
remote: 
remote: update type    : tags-commit
remote: This update type currently unsupported by hooks.
remote: hooklet hooks/update.secondary.d/update_safe failed
remote: hooks/update.secondary died
remote: error: hook declined to update refs/tags/rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
To gitolite@at-git:meta-altera
 ! [remote rejected] rel_angstrom-v2014.12-yocto1.7_16.09.02_pr -> rel_angstrom-v2014.12-yocto1.7_16.09.02_pr (hook declined)
error: failed to push some refs to 'gitolite@at-git:meta-altera'
atull@linuxheads99:~/repos/internal/meta-altera$ git push -f origin :rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
\033[1;31m###############################################################
###############################################################
This system is for the use of Altera authorized users only.  
Individuals using this computing system without authority, or
in excess of their authority, are subject to having all of   
their activities on this system monitored and recorded by the
system personnel.                                            
In the course of monitoring individuals improperly using this
system, or in the course of system maintenance, the activities
of authorized users may be monitored.  Anyone using this 
system expressly consents to such monitoring and is advised 
that if such monitoring reveals possible evidence of criminal 
activity, system personnel may provide the evidence of such 
monitoring to law enforcement officials.
###############################################################
###############################################################\033[0m
remote: testing
remote: /usr/local/git/repositories/meta-altera.git
remote: update_safe refs/tags/rel_angstrom-v2014.12-yocto1.7_16.09.02_pr cdd748a29b91ab8adb13b6c3df883854388258a5 0000000000000000000000000000000000000000
remote: 
remote:  ***********************************************************************************************
remote:  *** If you have problems with a git push, please send this whole log along with the patches ***
remote:  *** you are trying to push to Alan and Yves (atull@altera.com and yvanderv@altera.com)      ***
remote:  ***                                                                                         ***
remote:  *** Common mistakes: doing 'git-pull', 'git-merge', or pushing to a branch without first    ***
remote:  *** updating (git fetch origin && git rebase)                                               ***
remote:  ***                                                                                         ***
remote:  *** see also:                                                                               ***
remote:  *** linux-socfpga/Documentation/CodingStyle                                                 ***
remote:  *** http://sw-wiki.altera.com/twiki/bin/view/Software/HPSLinuxDevelopmentFlow               ***
remote:  *** http://sw-wiki.altera.com/twiki/bin/view/Software/HPSLinuxGITQuickIntroduction          ***
remote:  ***********************************************************************************************
remote: 
remote: update type    : tags-delete
remote: refname       : refs/tags/rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
remote: oldrev        : cdd748a29b91ab8adb13b6c3df883854388258a5
remote: newrev        : 0000000000000000000000000000000000000000
remote: 
remote: repo          : meta-altera
remote: # of commits  : 0
remote: refs path     : tags
remote: newrev_type   : delete
remote: 
remote: delete tag    : rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
remote: allowed
To gitolite@at-git:meta-altera
 - [deleted]         rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
atull@linuxheads99:~/repos/internal/meta-altera$ git push -f origin rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
\033[1;31m###############################################################
###############################################################
This system is for the use of Altera authorized users only.  
Individuals using this computing system without authority, or
in excess of their authority, are subject to having all of   
their activities on this system monitored and recorded by the
system personnel.                                            
In the course of monitoring individuals improperly using this
system, or in the course of system maintenance, the activities
of authorized users may be monitored.  Anyone using this 
system expressly consents to such monitoring and is advised 
that if such monitoring reveals possible evidence of criminal 
activity, system personnel may provide the evidence of such 
monitoring to law enforcement officials.
###############################################################
###############################################################\033[0m
Total 0 (delta 0), reused 0 (delta 0)
remote: testing
remote: /usr/local/git/repositories/meta-altera.git
remote: update_safe refs/tags/rel_angstrom-v2014.12-yocto1.7_16.09.02_pr 0000000000000000000000000000000000000000 d6f1376455ff9341a67e44bbcb0253d5e78883a4
remote: 
remote:  ***********************************************************************************************
remote:  *** If you have problems with a git push, please send this whole log along with the patches ***
remote:  *** you are trying to push to Alan and Yves (atull@altera.com and yvanderv@altera.com)      ***
remote:  ***                                                                                         ***
remote:  *** Common mistakes: doing 'git-pull', 'git-merge', or pushing to a branch without first    ***
remote:  *** updating (git fetch origin && git rebase)                                               ***
remote:  ***                                                                                         ***
remote:  *** see also:                                                                               ***
remote:  *** linux-socfpga/Documentation/CodingStyle                                                 ***
remote:  *** http://sw-wiki.altera.com/twiki/bin/view/Software/HPSLinuxDevelopmentFlow               ***
remote:  *** http://sw-wiki.altera.com/twiki/bin/view/Software/HPSLinuxGITQuickIntroduction          ***
remote:  ***********************************************************************************************
remote: 
remote: update type    : tags-create
remote: refname       : refs/tags/rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
remote: oldrev        : 0000000000000000000000000000000000000000
remote: newrev        : d6f1376455ff9341a67e44bbcb0253d5e78883a4
remote: 
remote: repo          : meta-altera
remote: # of commits  : 0
remote: refs path     : tags
remote: newrev_type   : create
remote: 
remote: create tag    : rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
remote: allowed
remote: kickoff, repo=meta-altera
remote: http://jenkins-vm:8080/git/notifyCommit?url=gitolite@at-git:meta-altera&sha1=d6f1376455ff9341a67e44bbcb0253d5e78883a4
To gitolite@at-git:meta-altera
 * [new tag]         rel_angstrom-v2014.12-yocto1.7_16.09.02_pr -> rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
atull@linuxheads99:~/repos/internal/meta-altera$ git push -f portal rel_angstrom-v2014.12-yocto1.7_16.09.02_pr
Counting objects: 9, done.
Delta compression using up to 6 threads.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (9/9), 950 bytes | 0 bytes/s, done.
Total 9 (delta 5), reused 5 (delta 3)
remote: Resolving deltas: 100% (5/5), completed with 4 local objects.
To git@github.com:altera-opensource/meta-altera
 + cdd748a...d6f1376 rel_angstrom-v2014.12-yocto1.7_16.09.02_pr -> rel_angstrom-v2014.12-yocto1.7_16.09.02_pr (forced update)
atull@linuxheads99:~/repos/internal/meta-altera$ git push -f portal rel_angstrom-v2014.12-yocto1.7_16.09.02_pr:refs/heads/angstrom-v2014.12-yocto1.7
Total 0 (delta 0), reused 0 (delta 0)
To git@github.com:altera-opensource/meta-altera
 + cdd748a...d6f1376 rel_angstrom-v2014.12-yocto1.7_16.09.02_pr -> angstrom-v2014.12-yocto1.7 (forced update)
atull@linuxheads99:~/repos/internal/meta-altera$ 
