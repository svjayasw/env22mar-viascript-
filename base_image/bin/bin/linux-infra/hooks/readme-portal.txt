Git Hooks for the Portal

***********************************************************************************************
*** WARNING - Out of date documentation
***********************************************************************************************
We used to have a 'portal' server running gitolite before we moved our 'portal' git to github.
These notes may be interesting for historical reasons, but this doesn't explain anything
about our current portal
***********************************************************************************************

*** We do not have any custom hooks on the portal ***

But we need to enable post_update hook to do update-server-info

 * /usr/share/gitolite/hooks/common/ ==  where the gitolite hooks are

 * IMPORTANT NOTE: You *must* disable your editor from creating backup files.  Because
   when the update.secondary runs, it will run both update.secondary.d/lala and update.secondary.d/lala~
   for example.  Think about the effects...

===========================================================================================
Setting up this one hook on the portal git server
===========================================================================================
 * Set up hooks scripts
   $ cd /usr/share/gitolite/hooks/common

   # Enable post_update hook
   $ sudo cp /opt/gitolite/repositories/linux-socfpga.git/hooks/post-update.sample .
   $ sudo mv post-update.sample post-update
   $ sudo chmod 755 post-update

   # Run gl-setup to activate the hooks for gitolite
   $ sudo su - gitolite
   $ cd ~/.gitolite/hooks/common/
   $ gl-setup
   * Exit such that you are no longer the gitolite user.

For more info: http://gitolite.com/gitolite/g2/hooks.html
