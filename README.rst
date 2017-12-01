==============
Spark-Formula
==============

Formula to setup and configure specific versions of `Apache Spark`.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.


Available states
==================

.. contents::
   :local:

``spark``
------------
Install Apache Spark

``spark.worker``
------------
Installs and sets up a stand-alone spark worker/slave server

``spark.master``
------------
Installs and sets up a stand-alone spark master server.

``spark.debug``
-----------------
Helpful for debugging, dumps the jinja map to a text file in /tmp


Usage
=======

If all you need is the Spark environment, not a worker or master, add `spark` or `spark.env` to the topfile; Otherwise, add `spark.master` or `spark.worker` (or both!) to the appropriate include or topfile declaration.

.. code-block::
   # example top.sls
   '*':
     - spark
       
   'G@roles:spark-worker':
     - spark.worker

   'G@roles:spark-master':
     - spark.master

   
Overriding the pillar is 
Testing
=========

Requirements
------------

Testing is done with KitchenSalt_ which means you'll also need a working Ruby setup and preferably at least 2.2, but you can use whatever version as long as you update the `Gemfile`.  You will also need `bundler` installed and can be done so with `gem install bundler`.

If all that works, you should be able to run `kitchen test` which is an alias for `kitchen converge` + `kitchen verify` but it deletes the box on completion so it isn't very useful during development.  

.. _KitchenSalt: https://github.com/simonmcc/kitchen-salt

Cheat Sheet
------------

.. code-block::

   # Initial setup
   which bundle || gem install bundler
   bundle install
   
   # build vagrant box and run states
   kitchen converge
   
   # run tests in `test/integration/default`
   kitchen verify

   # sledgehammer
   kitchen destroy

   # alias for running  (destroy + converge + verify + destroy)
   kitchen test

  
