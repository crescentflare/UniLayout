package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.Button;

import com.crescentflare.unilayout.helpers.UniLayoutParams;

/**
 * UniLayout view: a simple button
 * Extends Button to use UniLayoutParams and provide some minor layout improvements
 */
public class UniButtonView extends Button
{
    // ---
    // Initialization
    // ---

    public UniButtonView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniButtonView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniButtonView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniButtonView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }
}
