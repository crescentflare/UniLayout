package com.crescentflare.unilayout.views;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.os.Build;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

import com.crescentflare.unilayout.containers.UniFrameContainer;
import com.crescentflare.unilayout.helpers.UniLayout;
import com.crescentflare.unilayout.helpers.UniLayoutParams;

import java.lang.ref.WeakReference;

/**
 * UniLayout view: a reusable view container
 * Provides a container with a customizable view and divider to be used in the UniReusingContainer
 */
public class UniReusableView extends UniFrameContainer
{
    // ---
    // Constants
    // ---

    private static final int SWIPE_ANIMATION_TIME = 200;


    // ---
    // Members
    // ---

    private WeakReference<OnClickListener> currentClickListener;
    private UniFrameContainer itemViewContainer;
    private UniFrameContainer underViewContainer;
    private View itemView;
    private View underView;
    private View itemBackgroundView;
    private View underBackgroundView;
    private View dividerView;
    private int backgroundColor = 0xffffffff;
    private int underBackgroundColor = 0xffefefef;
    private int highlightColor;
    private boolean swipedOpen = false;


    // ---
    // Initialization
    // ---

    public UniReusableView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniReusableView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniReusableView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniReusableView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
        UniLayoutParams layoutParams = new UniLayoutParams(LayoutParams.MATCH_PARENT, 1);
        dividerView = new View(getContext());
        dividerView.setBackgroundColor(0xffc0c0c0);
        layoutParams.verticalGravity = 1;
        dividerView.setLayoutParams(layoutParams);
        addView(dividerView);
        setHighlightColor(0xffc0c0c0);
    }


    // ---
    // Access values
    // ---

    public View getDividerView()
    {
        return dividerView;
    }

    public UniFrameContainer getItemContainerView()
    {
        return itemViewContainer;
    }

    public UniFrameContainer getUnderContainerView()
    {
        return underViewContainer;
    }

    public View getItemView()
    {
        return itemView;
    }

    public void setItemView(View itemView)
    {
        if (itemView == this.itemView)
        {
            return;
        }
        if (this.itemView != null)
        {
            removeView(itemViewContainer);
            itemViewContainer = null;
            itemBackgroundView = null;
        }
        this.itemView = itemView;
        if (itemView != null)
        {
            // Create the container
            itemViewContainer = new UniFrameContainer(getContext());
            itemViewContainer.setLayoutParams(new UniLayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
            addView(itemViewContainer, underViewContainer != null ? 1 : 0);

            // Add the background to the container
            itemBackgroundView = new View(getContext());
            itemBackgroundView.setLayoutParams(new UniLayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
            itemViewContainer.addView(itemBackgroundView);
            updateBackground();

            // Add the item view to the container
            UniLayoutParams layoutParams = new UniLayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
            if (itemView.getLayoutParams() != null)
            {
                if (itemView.getLayoutParams() instanceof MarginLayoutParams)
                {
                    MarginLayoutParams marginLayoutParams = (MarginLayoutParams)itemView.getLayoutParams();
                    layoutParams.topMargin = marginLayoutParams.topMargin;
                    layoutParams.bottomMargin = marginLayoutParams.bottomMargin;
                    layoutParams.leftMargin = marginLayoutParams.leftMargin;
                    layoutParams.rightMargin = marginLayoutParams.rightMargin;
                }
                if (itemView.getLayoutParams() instanceof UniLayoutParams)
                {
                    UniLayoutParams uniLayoutParams = (UniLayoutParams)itemView.getLayoutParams();
                    layoutParams.horizontalGravity = uniLayoutParams.horizontalGravity;
                    layoutParams.verticalGravity = uniLayoutParams.verticalGravity;
                    layoutParams.minWidth = uniLayoutParams.minWidth;
                    layoutParams.minHeight = uniLayoutParams.minHeight;
                    layoutParams.maxWidth = uniLayoutParams.maxWidth;
                    layoutParams.maxHeight = uniLayoutParams.maxHeight;
                }
            }
            itemView.setLayoutParams(layoutParams);
            itemViewContainer.addView(itemView);
            itemView.setSelected(isSelected());
            itemView.setEnabled(isEnabled());
        }
    }

    public View getUnderView()
    {
        return underView;
    }

    public void setUnderView(View underView)
    {
        if (underView == this.underView)
        {
            return;
        }
        if (this.underView != null)
        {
            removeView(underViewContainer);
            underViewContainer = null;
            underBackgroundView = null;
        }
        this.underView = underView;
        if (underView != null)
        {
            // Create the container
            underViewContainer = new UniFrameContainer(getContext());
            underViewContainer.setLayoutParams(new UniLayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
            addView(underViewContainer, 0);

            // Add the background to the container
            underBackgroundView = new View(getContext());
            underBackgroundView.setLayoutParams(new UniLayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
            underViewContainer.addView(underBackgroundView);
            underBackgroundView.setBackgroundColor(underBackgroundColor);

            // Add the under view to the container
            UniLayoutParams layoutParams = new UniLayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            if (underView.getLayoutParams() != null)
            {
                layoutParams.width = underView.getLayoutParams().width;
                if (underView.getLayoutParams() instanceof MarginLayoutParams)
                {
                    MarginLayoutParams marginLayoutParams = (MarginLayoutParams)underView.getLayoutParams();
                    layoutParams.topMargin = marginLayoutParams.topMargin;
                    layoutParams.bottomMargin = marginLayoutParams.bottomMargin;
                    layoutParams.leftMargin = marginLayoutParams.leftMargin;
                    layoutParams.rightMargin = marginLayoutParams.rightMargin;
                }
                if (underView.getLayoutParams() instanceof UniLayoutParams)
                {
                    UniLayoutParams uniLayoutParams = (UniLayoutParams)underView.getLayoutParams();
                    layoutParams.horizontalGravity = uniLayoutParams.horizontalGravity;
                    layoutParams.verticalGravity = uniLayoutParams.verticalGravity;
                    layoutParams.minWidth = uniLayoutParams.minWidth;
                    layoutParams.minHeight = uniLayoutParams.minHeight;
                    layoutParams.maxWidth = uniLayoutParams.maxWidth;
                    layoutParams.maxHeight = uniLayoutParams.maxHeight;
                }
            }
            underView.setLayoutParams(layoutParams);
            underViewContainer.addView(underView);
            underView.setEnabled(isEnabled());
        }
    }

    public void setBackgroundColor(int color)
    {
        backgroundColor = color;
        updateBackground();
    }

    public void setHighlightColor(int color)
    {
        highlightColor = color;
        updateBackground();
    }

    public void setUnderBackgroundColor(int color)
    {
        underBackgroundColor = color;
        if (underBackgroundView != null)
        {
            underBackgroundView.setBackgroundColor(underBackgroundColor);
        }
    }

    @Override
    public void setOnClickListener(@Nullable OnClickListener listener)
    {
        if (!swipedOpen)
        {
            super.setOnClickListener(listener);
        }
        if (listener != null)
        {
            currentClickListener = new WeakReference<OnClickListener>(listener);
        }
        else
        {
            currentClickListener = null;
        }
    }


    // ---
    // Set state
    // ---

    @Override
    public void setSelected(boolean selected)
    {
        setSelected(selected, false);
    }

    public void setSelected(boolean selected, boolean animated)
    {
        if (itemView != null)
        {
            boolean changedSelection = selected != itemView.isSelected();
            if (changedSelection)
            {
                if (itemView instanceof AnimatingItemView)
                {
                    ((AnimatingItemView)itemView).setSelected(selected, animated);
                }
                else
                {
                    itemView.setSelected(selected);
                }
            }
        }
        super.setSelected(selected);
    }

    @Override
    public void setEnabled(boolean enabled)
    {
        setSelected(enabled, false);
    }

    public void setEnabled(boolean enabled, boolean animated)
    {
        super.setEnabled(enabled);
        if (itemView != null)
        {
            if (itemView instanceof AnimatingItemView)
            {
                ((AnimatingItemView)itemView).setEnabled(enabled, animated);
            }
            else
            {
                itemView.setEnabled(enabled);
            }
        }
    }


    // ---
    // Swiping state
    // ---

    public void setSwipeTranslationX(float x)
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1)
        {
            if (itemViewContainer != null)
            {
                itemViewContainer.setTranslationX(x);
            }
        }
    }

    public void swipeOpen(boolean animated)
    {
        if (itemViewContainer != null)
        {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1)
            {
                if (animated)
                {
                    itemViewContainer.animate().setDuration(SWIPE_ANIMATION_TIME).translationX(-getWidth());
                }
                else
                {
                    itemViewContainer.setTranslationX(-getWidth());
                }
            }
            else
            {
                itemViewContainer.setVisibility(GONE);
            }
        }
        swipedOpen = true;
        super.setOnClickListener(null);
    }

    public void swipeClose(boolean animated)
    {
        if (itemViewContainer != null)
        {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1)
            {
                if (animated)
                {
                    itemViewContainer.animate().setDuration(SWIPE_ANIMATION_TIME).translationX(0);
                }
                else
                {
                    itemViewContainer.setTranslationX(0);
                }
            }
            else
            {
                itemViewContainer.setVisibility(VISIBLE);
            }
        }
        swipedOpen = false;
        if (currentClickListener != null && currentClickListener.get() != null)
        {
            super.setOnClickListener(currentClickListener.get());
        }
    }


    // ---
    // Helpers
    // ---

    private void updateBackground()
    {
        Drawable setDrawable;
        if (itemBackgroundView != null)
        {
            if (highlightColor != 0)
            {
                StateListDrawable drawable = new StateListDrawable();
                ColorDrawable selectedColorDrawable = new ColorDrawable(blendColor(backgroundColor, highlightColor));
                drawable.addState(new int[]{android.R.attr.state_selected}, selectedColorDrawable);
                drawable.addState(new int[]{android.R.attr.state_focused}, selectedColorDrawable);
                drawable.addState(new int[]{android.R.attr.state_pressed}, selectedColorDrawable);
                drawable.addState(new int[0], new ColorDrawable(backgroundColor));
                setDrawable = drawable;
            }
            else
            {
                setDrawable = new ColorDrawable(backgroundColor);
            }
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN)
            {
                itemBackgroundView.setBackgroundDrawable(setDrawable);
            }
            else
            {
                itemBackgroundView.setBackground(setDrawable);
            }
        }
    }

    private int blendColor(int first, int second)
    {
        int firstR = (first >> 16) & 0xFF;
        int firstG = (first >> 8) & 0xFF;
        int firstB = first & 0xFF;
        int secondA = (second >> 24) & 0xFF;
        int secondR = (second >> 16) & 0xFF;
        int secondG = (second >> 8) & 0xFF;
        int secondB = second & 0xFF;
        int resultR = firstR * (255 - secondA) / 255 + secondR * secondA / 255;
        int resultG = firstG * (255 - secondA) / 255 + secondG * secondA / 255;
        int resultB = firstB * (255 - secondA) / 255 + secondB * secondA / 255;
        return (first & 0xFF000000) + (resultR << 16) + (resultG << 8) + resultB;
    }


    // ---
    // Interface for a item view with optional animation
    // ---

    public interface AnimatingItemView
    {
        void setSelected(boolean selected, boolean animated);
        void setEnabled(boolean enabled, boolean animated);
    }
}
