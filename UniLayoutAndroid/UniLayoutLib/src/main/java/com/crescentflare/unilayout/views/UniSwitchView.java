package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.support.v7.widget.SwitchCompat;

/**
 * UniLayout view: a switch including text
 * Extends SwitchCompat, currently it's just an alias to have the same name as the iOS class
 */
public class UniSwitchView extends SwitchCompat
{
    // ---
    // Initialization
    // ---

    public UniSwitchView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniSwitchView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniSwitchView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniSwitchView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }
}
