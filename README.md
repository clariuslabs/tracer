# ![Icon](https://raw.github.com/clariuslabs/NuTracer/master/icon/32.png) NuTracer

NuTracer is a minimalist unified tracing/logging interface that abstracts the specific logging libraries from consuming code. This allows you to start coding your projects right away without having to buy into a logging framework up-front, but still start building a strong foundation of tracing messages that will help diagnose problems down the road.

It's designed to optimize the existing capabilities of the underlying libraries without compromising their performance or features.

It provides adapters for System.Diagnostics, log4net, NLog and Enterprise Library Logging.

## Why
Tracing or logging is something everyone needs to consider and adopt from day one in any application. Having to decide on a specific framework or library up-front, and spreading that implementation-specific code throughout the code base is simply too risky. Why not just start with the simplest possible abstraction and decide on the implementation later and in a single place, the bootstrapping/app start?

## Where
You can get Tracer at:

- [System.Diagnostics adapter](http://kzu.to/PEiP2S)
- [Main interfaces](http://kzu.to/PEgjcT)
- [log4net adapter](http://kzu.to/PEgl4A)
- [NLog adapter](http://kzu.to/PEgncC)
- [Enterprise Library Logging 5.0 adapter](http://kzu.to/PEgoxc)

Fork it on [GitHub](http://kzu.to/PEiUne).


### How
As elaborated in the [introductory blog post](http://kzu.to/PEgB3o "Tracer: the unified, dead-simple API for all logging frameworks in existence"), it's not worth it to introduce a binary dependency for something that is really extremely simple (just 3 types). So you install via [nuget](http://nuget.org/) the main interfaces in your "Common" or "Core" project which is shared by the components that will do the logging, by using:

`install-package tracer`
 
and then use the following code to retrieve a tracer and log to it:

	public class MyComponent
	{
		private static readonly ITracer tracer = Tracer.Get<MyComponent>();
	 
		public void DoSomething()
		{
			tracer.Info("Doing something...");
			...
		}
	}

Your bootstrapper or application startup code will take a dependency on a concrete adapter implementation mentioned in the Where section, and initialize the Tracer with the following line:

`Tracer.Initialize(new TracerManager());`

And that would be all!

All source code will be in your own project namespaces, and made internal by default. It's up to you to make it public or not!


You can read more about NuTracer in the [Wiki](https://github.com/clariuslabs/NuTracer/wiki).
