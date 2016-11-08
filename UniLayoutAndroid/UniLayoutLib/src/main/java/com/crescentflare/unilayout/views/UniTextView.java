package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.TextView;

/**
 * UniLayout view: a view with simple text
 * Extends TextView, currently it's just an alias to have the same name as the iOS class
 */
public class UniTextView extends TextView
{
    // ---
    // Initialization
    // ---

    public UniTextView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniTextView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniTextView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniTextView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }
}
