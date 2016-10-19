package com.crescentflare.unilayoutexample;

import android.app.Application;
import android.content.Context;

/**
 * The singleton application context (containing the other singletons in the app)
 */
public class ExampleApplication extends Application
{
    /**
     * Global context member
     */
    public static Context context = null;


    /**
     * Initialization
     */
    @Override
    public void onCreate()
    {
        super.onCreate();
        context = this;
    }
}
