package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.ProgressBar;

/**
 * UniLayout view: a spinner animation
 * Extends ProgressBar, currently it's just an alias to have the same name as the iOS class
 */
public class UniSpinnerView extends ProgressBar
{
    // ---
    // Initialization
    // ---

    public UniSpinnerView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniSpinnerView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniSpinnerView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniSpinnerView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }
}
