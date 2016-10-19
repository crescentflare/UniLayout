package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.TextView;

import com.crescentflare.unilayout.helpers.UniLayoutParams;

/**
 * UniLayout view: a view with simple text
 * Extends TextView to use UniLayoutParams and provide some minor layout improvements
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
        setLayoutParams(new UniLayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
    }
}
