delayed-method
---------------

Requires the resque gem.

Allows you to move a long run method to background to be processed later by resque

I have to come up with this because all other resque based delayed execution gem out there that I have tried is complex, buggy and doesn't work.

This delayed-method is designed to be deadly simple, doesn't hack deep into resque itself (so it is more likely to continue to work, even with further internal change of resque)

Infact, it just rely on Resque.enqueue at the deepest level. It doesn't deal with serialization, so it won't have any problem with serialization

Installation
============

    $ gem install delayed-method


Usage
============

  Given you have this long call inside your web request:

Executor.long_call(arg1, arg2)

  then you can easily move it to the delayed queue in background with this:

DelayedMethod.enqueue(Executor, :long_call, arg1, arg2)

  Or if you use active record model:

model.long_call(arg1, arg2)

  then you can easily move it to the delayed queue in background with this:

DelayedMethod.enqueue(model, :long_call, arg1, arg2)


That's it. This is the only 2 cases that DelayedMethod will work.


Warning
===========

Please notice that Class method call and ActiveRecord instance call are the only 2 cases supported.
Even in that case, only simple arguments (string, number) are supported.
Using object, structure, or symbol as argument will yield unexpected result. (Symbol will be converted to String).

delayed-method is only that simple and will always be that simple.
I don't want to promise a bundle of complex serialization or shit that will eventually turn into something sophisticated, easily fall apart when either resque or rails updated.

Author
=====

Phuong Nguyen:: phuongnd08@gmail.com
